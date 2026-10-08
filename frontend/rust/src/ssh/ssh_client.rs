use crate::frb_generated::StreamSink;
use ssh2::{Channel, Session};
use std::io::{ErrorKind, Read, Write};
use std::net::TcpStream;
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

pub(crate) enum ConnectionAuthentication {
    Password(String),
    Key(String),
}

pub(crate) struct ConnectionInformation {
    pub(crate) host: String,
    pub(crate) port: u16,
    pub(crate) username: String,
    pub(crate) authentication: ConnectionAuthentication,
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

pub(crate) struct SshClient {
    connection_information: ConnectionInformation,
}

impl SshClient {
    pub(crate) fn new(connection_information: ConnectionInformation) -> Self {
        SshClient { connection_information }
    }

    pub(crate) fn connect(&self, rows: u32, columns: u32) -> Result<SshConnection, String> {
        let tcp_connection_string = format!(
            "{}:{}",
            self.connection_information.host, self.connection_information.port
        );
        let tcp_stream = TcpStream::connect(tcp_connection_string).map_err(|e| e.to_string())?;
        let mut session = Session::new().map_err(|e| e.to_string())?;
        session.set_tcp_stream(tcp_stream);
        session.handshake().map_err(|e| e.to_string())?;

        match &self.connection_information.authentication {
            ConnectionAuthentication::Password(password) => {
                session
                    .userauth_password(&self.connection_information.username, password)
                    .map_err(|e| e.to_string())?;
            }
            ConnectionAuthentication::Key(key) => {
                session
                    .userauth_pubkey_memory(&self.connection_information.username, None, key, None)
                    .map_err(|e| e.to_string())?;
            }
        }

        SshConnection::new(session, rows, columns)
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
