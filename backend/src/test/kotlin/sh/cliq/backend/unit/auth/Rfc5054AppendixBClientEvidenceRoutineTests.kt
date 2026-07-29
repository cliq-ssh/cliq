package sh.cliq.backend.unit.auth

import com.nimbusds.srp6.SRP6ClientEvidenceContext
import com.nimbusds.srp6.SRP6CryptoParams
import org.junit.jupiter.api.Test
import sh.cliq.backend.auth.service.nimbus.Rfc5054AppendixBClientEvidenceRoutine
import java.math.BigInteger
import java.security.MessageDigest
import kotlin.test.assertEquals

class Rfc5054AppendixBClientEvidenceRoutineTests {
    @Test
    fun `computes RFC 5054 client evidence with a padded generator`() {
        assertEvidenceMatchesReference("SHA-256", "alice")
    }

    @Test
    fun `uses the configured digest and UTF-8 user identity`() {
        assertEvidenceMatchesReference("SHA-512", "álïce")
    }

    private fun assertEvidenceMatchesReference(hashAlgorithm: String, userId: String) {
        val modulus = BigInteger("0102030405", 16)
        val generator = BigInteger.TWO
        val context = SRP6ClientEvidenceContext(
            userId,
            BigInteger("010203", 16),
            BigInteger("010001", 16),
            BigInteger("020003", 16),
            BigInteger("030405", 16),
        )
        val config = SRP6CryptoParams(modulus, generator, hashAlgorithm)

        val evidence = Rfc5054AppendixBClientEvidenceRoutine.computeClientEvidence(config, context)

        assertEquals(referenceEvidence(hashAlgorithm, modulus, generator, context), evidence)
    }

    private fun referenceEvidence(
        hashAlgorithm: String,
        modulus: BigInteger,
        generator: BigInteger,
        context: SRP6ClientEvidenceContext,
    ): BigInteger {
        val digest = MessageDigest.getInstance(hashAlgorithm)
        val modulusBytes = modulus.toUnsignedBytes()
        val paddedGenerator = generator.toUnsignedBytes().padStart(modulusBytes.size)
        val modulusXorGenerator = BigInteger(1, digest.digest(modulusBytes))
            .xor(BigInteger(1, digest.digest(paddedGenerator)))

        val input = listOf(
            modulusXorGenerator.toUnsignedBytes(),
            digest.digest(context.userID.toByteArray(Charsets.UTF_8)),
            context.s.toUnsignedBytes(),
            context.A.toUnsignedBytes(),
            context.B.toUnsignedBytes(),
            digest.digest(context.S.toUnsignedBytes()),
        ).fold(ByteArray(0)) { accumulated, bytes -> accumulated + bytes }

        return BigInteger(1, digest.digest(input))
    }

    private fun BigInteger.toUnsignedBytes(): ByteArray = toByteArray().let { bytes ->
        if (bytes.size > 1 && bytes[0] == 0.toByte()) bytes.copyOfRange(1, bytes.size) else bytes
    }

    private fun ByteArray.padStart(length: Int): ByteArray = ByteArray(length - size) + this
}
