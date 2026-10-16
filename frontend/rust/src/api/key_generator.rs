use crate::ssh::key_generator::{GeneratedSshKey, SshKeyGenerator, SshKeyType};

/// Generates a key pair of the given type with an optional comment.
/// If a passphrase is provided, the key will be encrypted.
pub fn generate_ssh_key(
    key_type: SshKeyType,
    comment: Option<String>,
    passphrase: Option<String>,
) -> Result<GeneratedSshKey, String> {
    SshKeyGenerator::generate(key_type, comment, passphrase)
}
