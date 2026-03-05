package app.cliq.backend.support.encryption

import org.bouncycastle.crypto.AsymmetricCipherKeyPair
import org.bouncycastle.crypto.generators.Argon2BytesGenerator
import org.bouncycastle.crypto.generators.X25519KeyPairGenerator
import org.bouncycastle.crypto.params.Argon2Parameters
import org.bouncycastle.crypto.params.X25519KeyGenerationParameters
import org.bouncycastle.crypto.params.X25519PrivateKeyParameters
import org.bouncycastle.crypto.params.X25519PublicKeyParameters
import org.springframework.boot.test.context.TestComponent
import java.security.SecureRandom

@TestComponent
class KeyAndHashHelper(
    private val secureRandom: SecureRandom = SecureRandom.getInstanceStrong(),
) {
    fun buildArgon2BytesGenerator(salt: ByteArray): Argon2BytesGenerator {
        val builder =
            Argon2Parameters
                .Builder(Argon2Parameters.ARGON2_id)
                .withVersion(Argon2Parameters.ARGON2_VERSION_13)
                .withMemoryAsKB(65_536) // 64MB
                .withSalt(salt)
                .withIterations(2)
                .withParallelism(1)
        val params = builder.build()

        val generator = Argon2BytesGenerator()
        generator.init(params)

        return generator
    }

    fun generateUserMasterKey(
        password: String,
        salt: ByteArray,
    ): ByteArray {
        val argon2Generator = buildArgon2BytesGenerator(salt)
        val userMasterKey = ByteArray(32)
        argon2Generator.generateBytes(password.toByteArray(), userMasterKey)

        return userMasterKey
    }

    fun generateDataEncryptionKey(): ByteArray {
        val dataEncryptionKey = ByteArray(32)
        secureRandom.nextBytes(dataEncryptionKey)

        return dataEncryptionKey
    }

    /**
     * @return Pair(publicKey, privateKey)
     */
    fun generateX25519KeyPair(): Pair<ByteArray, ByteArray> {
        val generator = this.getX25519KeyPairGenerator()

        val keyPair: AsymmetricCipherKeyPair = generator.generateKeyPair()

        val privateKeyParams = keyPair.private as X25519PrivateKeyParameters
        val publicKeyParams = keyPair.public as X25519PublicKeyParameters

        val privateKey = ByteArray(X25519PrivateKeyParameters.KEY_SIZE)
        val publicKey = ByteArray(X25519PublicKeyParameters.KEY_SIZE)

        privateKeyParams.encode(privateKey, 0)
        publicKeyParams.encode(publicKey, 0)

        return publicKey to privateKey
    }

    private fun getX25519KeyPairGenerator(): X25519KeyPairGenerator {
        val random = SecureRandom()
        val params = X25519KeyGenerationParameters(random)

        val generator = X25519KeyPairGenerator()
        generator.init(params)

        return generator
    }
}
