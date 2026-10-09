use crate::frb_generated::StreamSink;
use crate::ssh::ssh_client::{SftpConnection, SftpFileHandle, SshConnection, connect_session};

pub fn connect_ssh(
    host: String,
    port: u16,
    username: String,
    rows: u32,
    columns: u32,
    password: Option<String>,
    private_keys: Vec<String>,
    key_passphrases: Vec<Option<String>>,
    expected_host_key: Option<Vec<u8>>,
    skip_host_key_verification: bool,
) -> Result<SshConnection, String> {
    let session = connect_session(
        host,
        port,
        username,
        password,
        private_keys,
        key_passphrases,
        expected_host_key,
        skip_host_key_verification,
    )?;
    SshConnection::new(session, rows, columns)
}

pub fn connect_sftp(
    host: String,
    port: u16,
    username: String,
    password: Option<String>,
    private_keys: Vec<String>,
    key_passphrases: Vec<Option<String>>,
    expected_host_key: Option<Vec<u8>>,
    skip_host_key_verification: bool,
) -> Result<SftpConnection, String> {
    let session = connect_session(
        host,
        port,
        username,
        password,
        private_keys,
        key_passphrases,
        expected_host_key,
        skip_host_key_verification,
    )?;
    SftpConnection::new(session)
}

impl SshConnection {
    pub fn write_input(&self, data: Vec<u8>) -> Result<(), String> {
        self.write(data)
    }

    pub fn resize(&self, columns: u32, rows: u32, pixel_width: u32, pixel_height: u32) -> Result<(), String> {
        self.resize_terminal(columns, rows, pixel_width, pixel_height)
    }

    pub fn output(&mut self, output: StreamSink<Vec<u8>>) -> Result<(), String> {
        self.start_output(output)
    }
}

impl SftpConnection {
    pub fn open_read(&self, path: String) -> Result<SftpFileHandle, String> {
        self.open_read_inner(path)
    }

    pub fn open_write(&self, path: String, truncate: bool) -> Result<SftpFileHandle, String> {
        self.open_write_inner(path, truncate)
    }

    pub fn listdir(&self, path: String) -> Result<Vec<crate::ssh::ssh_client::SftpName>, String> {
        self.listdir_inner(path)
    }

    pub fn stat(&self, path: String) -> Result<crate::ssh::ssh_client::SftpFileAttr, String> {
        self.stat_inner(path)
    }

    pub fn absolute(&self, path: String) -> Result<String, String> {
        self.absolute_inner(path)
    }

    pub fn mkdir(&self, path: String) -> Result<(), String> {
        self.mkdir_inner(path)
    }

    pub fn rename(&self, old_path: String, new_path: String) -> Result<(), String> {
        self.rename_inner(old_path, new_path)
    }

    pub fn remove(&self, path: String) -> Result<(), String> {
        self.remove_inner(path)
    }

    pub fn rmdir(&self, path: String) -> Result<(), String> {
        self.rmdir_inner(path)
    }

    pub fn read_file_chunk(&self, path: String, offset: u64, max_bytes: u32) -> Result<Vec<u8>, String> {
        self.read_file_chunk_inner(path, offset, max_bytes)
    }

    pub fn write_file_chunk(&self, path: String, offset: u64, data: Vec<u8>, truncate: bool) -> Result<(), String> {
        self.write_file_chunk_inner(path, offset, data, truncate)
    }
}

impl SftpFileHandle {
    pub fn read_chunk(&self, max_bytes: u32) -> Result<Vec<u8>, String> {
        self.read_chunk_inner(max_bytes)
    }

    pub fn write_chunk(&self, data: Vec<u8>) -> Result<(), String> {
        self.write_chunk_inner(data)
    }
}
