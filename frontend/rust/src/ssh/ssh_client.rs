use ssh2::Session;
use std::net::TcpStream;

const TERM: &str = "xterm-256color";

pub(crate) enum ConnectionAuthentication {
    Password(String),
    Key(String),
}

pub(crate) struct ConnectionInformation {
    host: String,
    port: u16,
    username: String,
    authentication: ConnectionAuthentication,
}

pub(crate) struct SshConnection {
    session: Session,
}

impl SshConnection {
    pub(crate) fn new(session: Session) -> Self {
        SshConnection { session }
    }
}

pub(crate) struct SshClient {
    connection_information: ConnectionInformation,
}

impl SshClient {
    pub(crate) fn new(connection_information: ConnectionInformation) -> Self {
        SshClient { connection_information }
    }

    pub(crate) fn connect(&self) -> Result<(), String> {
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
                    .userauth_password(&self.connection_information.username, &password)
                    .map_err(|e| e.to_string())?;
            }
            ConnectionAuthentication::Key(key) => {
                session
                    .userauth_pubkey_memory(&self.connection_information.username, None, &key, None)
                    .map_err(|e| e.to_string())?;
            }
        }
        let mut channel = session.channel_session().map_err(|e| e.to_string())?;
        // TODO: set columns
        channel.request_pty(TERM, None, None).map_err(|e| e.to_string())?;
        channel.shell().map_err(|e| e.to_string())?;

        let connection = SshConnection::new(session);

        // Implement SSH connection logic here
        Ok(())
    }
}
