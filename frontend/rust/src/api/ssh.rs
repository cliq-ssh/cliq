use crate::frb_generated::StreamSink;
use crate::ssh::ssh_client::{ConnectionAuthentication, ConnectionInformation, SshClient, SshConnection};

pub fn connect_ssh(
    host: String,
    port: u16,
    username: String,
    rows: u32,
    columns: u32,
    password: Option<String>,
    private_key: Option<String>,
) -> Result<SshConnection, String> {
    let authentication = match (password, private_key) {
        (Some(password), None) => ConnectionAuthentication::Password(password),
        (None, Some(key)) => ConnectionAuthentication::Key(key),
        (Some(_), Some(_)) => return Err("Specify either a password or a private key".to_string()),
        (None, None) => return Err("An authentication method is required".to_string()),
    };

    SshClient::new(ConnectionInformation {
        host,
        port,
        username,
        authentication,
    })
    .connect(rows, columns)
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
