use crate::frb_generated::StreamSink;
use base64::{Engine as _, engine::general_purpose::STANDARD};
use ssh2::{Channel, HashType, HostKeyType, OpenFlags, OpenType, Session, Sftp};
use std::io::{ErrorKind, Read, Seek, SeekFrom, Write};
use std::net::TcpStream;
use std::path::Path;
use std::sync::Mutex;
use std::sync::mpsc::{self, Receiver, SyncSender};
use std::thread;
use std::time::Duration;

const TERM: &str = "xterm-256color";

enum ChannelInput {
    Data(Vec<u8>),
    Resize {
        columns: u32,
        rows: u32,
        pixel_width: u32,
        pixel_height: u32,
    },
}

pub struct SshConnection {
    channel: Option<Channel>,
    input: SyncSender<ChannelInput>,
    input_receiver: Mutex<Option<Receiver<ChannelInput>>>,
}

impl SshConnection {
    pub(crate) fn new(session: Session, rows: u32, columns: u32) -> Result<Self, String> {
        session.set_blocking(true);
        let mut channel = session.channel_session().map_err(|e| e.to_string())?;
        channel
            .request_pty(TERM, None, Some((columns, rows, 0, 0)))
            .map_err(|e| e.to_string())?;
        channel.shell().map_err(|e| e.to_string())?;
        session.set_blocking(false);

        let (input, input_receiver) = mpsc::sync_channel::<ChannelInput>(256);

        Ok(SshConnection {
            channel: Some(channel),
            input,
            input_receiver: Mutex::new(Some(input_receiver)),
        })
    }

    pub(crate) fn write(&self, data: Vec<u8>) -> Result<(), String> {
        self.input.send(ChannelInput::Data(data)).map_err(|e| e.to_string())
    }

    pub(crate) fn resize_terminal(
        &self,
        columns: u32,
        rows: u32,
        pixel_width: u32,
        pixel_height: u32,
    ) -> Result<(), String> {
        self.input
            .send(ChannelInput::Resize {
                columns,
                rows,
                pixel_width,
                pixel_height,
            })
            .map_err(|e| e.to_string())
    }

    pub(crate) fn start_output(&mut self, sink: StreamSink<Vec<u8>>) -> Result<(), String> {
        let mut channel = self
            .channel
            .take()
            .ok_or_else(|| "SSH output stream already started".to_string())?;
        let input_receiver = self
            .input_receiver
            .lock()
            .map_err(|e| e.to_string())?
            .take()
            .ok_or_else(|| "SSH output stream already started".to_string())?;
        thread::spawn(move || run_channel(&mut channel, input_receiver, sink));
        Ok(())
    }
}

pub(crate) fn connect_session(
    host: String,
    port: u16,
    username: String,
    password: Option<String>,
    private_keys: Vec<String>,
    key_passphrases: Vec<Option<String>>,
    expected_host_key: Option<Vec<u8>>,
    skip_host_key_verification: bool,
) -> Result<Session, String> {
    let address = format!("{host}:{port}");
    let tcp_stream = TcpStream::connect(address).map_err(|e| e.to_string())?;
    let mut session = Session::new().map_err(|e| e.to_string())?;
    session.set_tcp_stream(tcp_stream);
    session.handshake().map_err(|e| e.to_string())?;

    let host_key = session
        .host_key()
        .ok_or_else(|| "The server did not provide a host key".to_string())?;
    let fingerprint = session
        .host_key_hash(HashType::Sha256)
        .ok_or_else(|| "Unable to calculate the host key fingerprint".to_string())?;
    let fingerprint = format!("SHA256:{}", STANDARD.encode(fingerprint).trim_end_matches('='));
    let fingerprint_matches = expected_host_key.as_deref() == Some(fingerprint.as_bytes());
    let raw_key_matches = expected_host_key.as_deref() == Some(host_key.0);
    if !skip_host_key_verification && !fingerprint_matches && !raw_key_matches {
        return Err(format!(
            "HOST_KEY|{}|{}|{}",
            host_key_algorithm(host_key.1),
            fingerprint,
            STANDARD.encode(fingerprint.as_bytes())
        ));
    }

    if let Some(password) = password {
        session
            .userauth_password(&username, &password)
            .map_err(|e| e.to_string())?;
    } else {
        if private_keys.is_empty() {
            return Err("An authentication method is required".to_string());
        }
        let mut last_error = None;
        for (index, private_key) in private_keys.iter().enumerate() {
            let passphrase = key_passphrases.get(index).and_then(Option::as_deref);
            match session.userauth_pubkey_memory(&username, None, private_key, passphrase) {
                Ok(()) => {
                    last_error = None;
                    break;
                }
                Err(error) => last_error = Some(error.to_string()),
            }
        }
        if let Some(error) = last_error {
            return Err(error);
        }
    }
    if !session.authenticated() {
        return Err("SSH authentication failed".to_string());
    }
    Ok(session)
}

fn host_key_algorithm(key_type: HostKeyType) -> &'static str {
    match key_type {
        HostKeyType::Rsa => "ssh-rsa",
        HostKeyType::Dss => "ssh-dss",
        HostKeyType::Ecdsa256 => "ecdsa-sha2-nistp256",
        HostKeyType::Ecdsa384 => "ecdsa-sha2-nistp384",
        HostKeyType::Ecdsa521 => "ecdsa-sha2-nistp521",
        HostKeyType::Ed25519 => "ssh-ed25519",
        HostKeyType::Unknown => "unknown",
    }
}

pub struct SftpConnection {
    sftp: Sftp,
}

pub struct SftpFileHandle {
    file: Mutex<ssh2::File>,
}

#[derive(Clone)]
pub struct SftpFileAttr {
    pub size: Option<u64>,
    pub mode: u32,
    pub modify_time: Option<u64>,
    pub access_time: Option<u64>,
}

#[derive(Clone)]
pub struct SftpName {
    pub filename: String,
    pub longname: String,
    pub attr: SftpFileAttr,
}

fn file_attr(stat: &ssh2::FileStat) -> SftpFileAttr {
    SftpFileAttr {
        size: stat.size,
        mode: stat.perm.unwrap_or_default(),
        modify_time: stat.mtime,
        access_time: stat.atime,
    }
}

impl SftpConnection {
    pub(crate) fn new(session: Session) -> Result<Self, String> {
        session.sftp().map(|sftp| Self { sftp }).map_err(|e| e.to_string())
    }

    pub(crate) fn listdir_inner(&self, path: String) -> Result<Vec<SftpName>, String> {
        self.sftp
            .readdir(Path::new(&path))
            .map_err(|e| e.to_string())
            .map(|entries| {
                entries
                    .into_iter()
                    .map(|(path, stat)| {
                        let filename = path
                            .file_name()
                            .and_then(|name| name.to_str())
                            .unwrap_or_default()
                            .to_string();
                        SftpName {
                            filename: filename.clone(),
                            longname: filename,
                            attr: file_attr(&stat),
                        }
                    })
                    .collect()
            })
    }

    pub(crate) fn stat_inner(&self, path: String) -> Result<SftpFileAttr, String> {
        self.sftp
            .stat(Path::new(&path))
            .map(|s| file_attr(&s))
            .map_err(|e| e.to_string())
    }

    pub(crate) fn absolute_inner(&self, path: String) -> Result<String, String> {
        self.sftp
            .realpath(Path::new(&path))
            .map(|path| path.to_string_lossy().into_owned())
            .map_err(|e| e.to_string())
    }

    pub(crate) fn mkdir_inner(&self, path: String) -> Result<(), String> {
        self.sftp.mkdir(Path::new(&path), 0o755).map_err(|e| e.to_string())
    }

    pub(crate) fn rename_inner(&self, old_path: String, new_path: String) -> Result<(), String> {
        self.sftp
            .rename(Path::new(&old_path), Path::new(&new_path), None)
            .map_err(|e| e.to_string())
    }

    pub(crate) fn remove_inner(&self, path: String) -> Result<(), String> {
        self.sftp.unlink(Path::new(&path)).map_err(|e| e.to_string())
    }

    pub(crate) fn rmdir_inner(&self, path: String) -> Result<(), String> {
        self.sftp.rmdir(Path::new(&path)).map_err(|e| e.to_string())
    }

    pub(crate) fn read_file_chunk_inner(&self, path: String, offset: u64, max_bytes: u32) -> Result<Vec<u8>, String> {
        let mut file = self.sftp.open(Path::new(&path)).map_err(|e| e.to_string())?;
        file.seek(SeekFrom::Start(offset)).map_err(|e| e.to_string())?;
        let mut buffer = vec![0; max_bytes as usize];
        let count = file.read(&mut buffer).map_err(|e| e.to_string())?;
        buffer.truncate(count);
        Ok(buffer)
    }

    pub(crate) fn open_read_inner(&self, path: String) -> Result<SftpFileHandle, String> {
        self.sftp
            .open(Path::new(&path))
            .map(|file| SftpFileHandle { file: Mutex::new(file) })
            .map_err(|e| e.to_string())
    }

    pub(crate) fn open_write_inner(&self, path: String, truncate: bool) -> Result<SftpFileHandle, String> {
        let flags = if truncate {
            OpenFlags::WRITE | OpenFlags::CREATE | OpenFlags::TRUNCATE
        } else {
            OpenFlags::WRITE | OpenFlags::CREATE
        };
        self.sftp
            .open_mode(Path::new(&path), flags, 0o644, OpenType::File)
            .map(|file| SftpFileHandle { file: Mutex::new(file) })
            .map_err(|e| e.to_string())
    }

    pub(crate) fn write_file_chunk_inner(
        &self,
        path: String,
        offset: u64,
        data: Vec<u8>,
        truncate: bool,
    ) -> Result<(), String> {
        let flags = if truncate {
            OpenFlags::WRITE | OpenFlags::TRUNCATE
        } else {
            OpenFlags::WRITE | OpenFlags::CREATE
        };
        let mut file = self
            .sftp
            .open_mode(Path::new(&path), flags, 0o644, OpenType::File)
            .map_err(|e| e.to_string())?;
        file.seek(SeekFrom::Start(offset)).map_err(|e| e.to_string())?;
        file.write_all(&data).map_err(|e| e.to_string())
    }
}

impl SftpFileHandle {
    pub(crate) fn read_chunk_inner(&self, max_bytes: u32) -> Result<Vec<u8>, String> {
        let mut file = self.file.lock().map_err(|e| e.to_string())?;
        let mut buffer = vec![0; max_bytes as usize];
        let count = file.read(&mut buffer).map_err(|e| e.to_string())?;
        buffer.truncate(count);
        Ok(buffer)
    }

    pub(crate) fn write_chunk_inner(&self, data: Vec<u8>) -> Result<(), String> {
        let mut file = self.file.lock().map_err(|e| e.to_string())?;
        file.write_all(&data).map_err(|e| e.to_string())
    }
}

fn run_channel(channel: &mut Channel, input_receiver: mpsc::Receiver<ChannelInput>, sink: StreamSink<Vec<u8>>) {
    let mut output = [0; 8192];

    loop {
        match channel.read(&mut output) {
            Ok(0) => break,
            Ok(count) => {
                if sink.add(output[..count].to_vec()).is_err() {
                    break;
                }
            }
            Err(error) if error.kind() == ErrorKind::WouldBlock => {}
            Err(error) => {
                eprintln!("SSH channel read failed: {error}");
                break;
            }
        }

        match input_receiver.try_recv() {
            Ok(ChannelInput::Data(data)) => {
                if channel.write_all(&data).is_err() || channel.flush().is_err() {
                    break;
                }
            }
            Ok(ChannelInput::Resize {
                columns,
                rows,
                pixel_width,
                pixel_height,
            }) => {
                if channel
                    .request_pty_size(columns, rows, Some(pixel_width), Some(pixel_height))
                    .is_err()
                {
                    break;
                }
            }
            Err(mpsc::TryRecvError::Empty) => thread::sleep(Duration::from_millis(2)),
            Err(mpsc::TryRecvError::Disconnected) => break,
        }
    }
}
