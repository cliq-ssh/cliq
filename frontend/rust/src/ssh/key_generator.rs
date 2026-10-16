use ssh_key::{
    Algorithm, EcdsaCurve, LineEnding, PrivateKey,
    private::{KeypairData, RsaKeypair},
    rand_core::OsRng,
};

/// Supported ECDSA curve sizes (in bits).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum EcdsaBits {
    Bits256,
    Bits384,
    Bits521,
}

/// Supported RSA key sizes (in bits).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum RsaBits {
    Bits2048,
    Bits4096,
}

impl RsaBits {
    fn bits(self) -> usize {
        match self {
            RsaBits::Bits2048 => 2048,
            RsaBits::Bits4096 => 4096,
        }
    }
}

/// The type of SSH key to generate.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SshKeyType {
    Ed25519,
    Ecdsa(EcdsaBits),
    Rsa(RsaBits),
}

/// A generated SSH key pair in OpenSSH format.
#[derive(Debug, Clone)]
pub struct GeneratedSshKey {
    /// OpenSSH-formatted private key (PEM-like).
    pub private_key: String,
    /// OpenSSH-formatted public key (`ssh-ed25519 AAAA... comment`).
    pub public_key: String,
    /// SHA-256 fingerprint of the public key.
    pub fingerprint: String,
}

/// Generates SSH key pairs.
pub struct SshKeyGenerator;

impl SshKeyGenerator {
    /// Generates a key pair of the given type with an optional comment.
    pub fn generate(
        key_type: SshKeyType,
        comment: Option<String>,
        passphrase: Option<String>,
    ) -> Result<GeneratedSshKey, String> {
        let mut rng = OsRng;
        let mut key = match key_type {
            SshKeyType::Ed25519 => PrivateKey::random(&mut rng, Algorithm::Ed25519),
            SshKeyType::Ecdsa(bits) => {
                let curve = match bits {
                    EcdsaBits::Bits256 => EcdsaCurve::NistP256,
                    EcdsaBits::Bits384 => EcdsaCurve::NistP384,
                    EcdsaBits::Bits521 => EcdsaCurve::NistP521,
                };
                PrivateKey::random(&mut rng, Algorithm::Ecdsa { curve })
            }
            SshKeyType::Rsa(bits) => {
                RsaKeypair::random(&mut rng, bits.bits()).and_then(|kp| PrivateKey::new(KeypairData::from(kp), ""))
            }
        }
        .map_err(|e| e.to_string())?;

        if let Some(comment) = comment {
            key.set_comment(comment);
        }

        if let Some(passphrase) = passphrase {
            key = key.encrypt(&mut OsRng, passphrase).map_err(|e| e.to_string())?;
        }
        let private_key = key.to_openssh(LineEnding::LF).map_err(|e| e.to_string())?.to_string();
        let public = key.public_key();
        let public_key = public.to_openssh().map_err(|e| e.to_string())?;
        let fingerprint = public.fingerprint(Default::default()).to_string();

        Ok(GeneratedSshKey {
            private_key,
            public_key,
            fingerprint,
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    const DEFAULT_COMMENT: &str = "test";
    const DEFAULT_PASSPHRASE: &str = "password";

    fn check(t: SshKeyType, prefix: &str) {
        let k = SshKeyGenerator::generate(t, Some(DEFAULT_COMMENT.into()), None).unwrap();
        assert!(k.public_key.starts_with(prefix), "{}", k.public_key);
        assert!(k.private_key.contains("OPENSSH PRIVATE KEY"));
        assert!(k.fingerprint.starts_with("SHA256:"));
        assert!(PrivateKey::from_openssh(&k.private_key).is_ok());
    }

    fn check_encrypted(t: SshKeyType, prefix: &str) {
        let k = SshKeyGenerator::generate(t, Some(DEFAULT_COMMENT.into()), Some(DEFAULT_PASSPHRASE.into())).unwrap();
        assert!(k.public_key.starts_with(prefix), "{}", k.public_key);
        assert!(k.private_key.contains("OPENSSH PRIVATE KEY"));
        assert!(k.fingerprint.starts_with("SHA256:"));

        let parsed_key = PrivateKey::from_openssh(&k.private_key);
        assert!(parsed_key.is_ok());
        let parsed_key = parsed_key.unwrap();
        assert!(parsed_key.is_encrypted());
        assert!(parsed_key.decrypt("wrong").is_err());
        assert!(parsed_key.decrypt(DEFAULT_PASSPHRASE).is_ok());
    }

    #[test]
    fn ed25519() {
        check(SshKeyType::Ed25519, "ssh-ed25519 ");
    }

    #[test]
    fn ed25519_encrypted() {
        check_encrypted(SshKeyType::Ed25519, "ssh-ed25519 ");
    }

    #[test]
    fn ecdsa() {
        check(SshKeyType::Ecdsa(EcdsaBits::Bits256), "ecdsa-sha2-nistp256 ");
        check(SshKeyType::Ecdsa(EcdsaBits::Bits384), "ecdsa-sha2-nistp384 ");
        check(SshKeyType::Ecdsa(EcdsaBits::Bits521), "ecdsa-sha2-nistp521 ");
    }

    #[test]
    fn ecdsa_encrypted() {
        check_encrypted(SshKeyType::Ecdsa(EcdsaBits::Bits256), "ecdsa-sha2-nistp256 ");
        check_encrypted(SshKeyType::Ecdsa(EcdsaBits::Bits384), "ecdsa-sha2-nistp384 ");
        check_encrypted(SshKeyType::Ecdsa(EcdsaBits::Bits521), "ecdsa-sha2-nistp521 ");
    }

    #[test]
    fn rsa() {
        check(SshKeyType::Rsa(RsaBits::Bits2048), "ssh-rsa ");
        check(SshKeyType::Rsa(RsaBits::Bits4096), "ssh-rsa ");
    }

    #[test]
    fn rsa_encrypted() {
        check_encrypted(SshKeyType::Rsa(RsaBits::Bits2048), "ssh-rsa ");
        check_encrypted(SshKeyType::Rsa(RsaBits::Bits4096), "ssh-rsa ");
    }
}
