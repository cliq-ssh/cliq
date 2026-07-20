package sh.cliq.backend.auth.service.nimbus

import com.nimbusds.srp6.BigIntegerUtils
import com.nimbusds.srp6.ClientEvidenceRoutine
import com.nimbusds.srp6.SRP6ClientEvidenceContext
import com.nimbusds.srp6.SRP6CryptoParams
import com.nimbusds.srp6.SRP6ServerEvidenceContext
import com.nimbusds.srp6.ServerEvidenceRoutine
import java.math.BigInteger
import java.security.MessageDigest

object Rfc5054AppendixBClientEvidenceRoutine : ClientEvidenceRoutine {
    override fun computeClientEvidence(config: SRP6CryptoParams, ctx: SRP6ClientEvidenceContext): BigInteger {
        val digest = MessageDigest.getInstance(config.H)

        return computeRfc5054AppendixBM1(
            digest,
            config.N,
            config.g,
            ctx.userID,
            ctx.s,
            ctx.A,
            ctx.B,
            ctx.S,
        )
    }
}

object Rfc5054AppendixBServerEvidenceRoutine : ServerEvidenceRoutine {
    override fun computeServerEvidence(config: SRP6CryptoParams, ctx: SRP6ServerEvidenceContext): BigInteger {
        val digest = MessageDigest.getInstance(config.H)
        val hashedSessionKey = hashBigInteger(digest, ctx.S)
        digest.reset()
        digest.update(BigIntegerUtils.bigIntegerToBytes(ctx.A))
        digest.update(BigIntegerUtils.bigIntegerToBytes(ctx.M1))
        digest.update(hashedSessionKey)

        return BigIntegerUtils.bigIntegerFromBytes(digest.digest())
    }
}

private fun computeRfc5054AppendixBM1(
    digest: MessageDigest,
    safePrime: BigInteger,
    generator: BigInteger,
    userId: String,
    salt: BigInteger,
    publicA: BigInteger,
    publicB: BigInteger,
    sessionKey: BigInteger,
): BigInteger {
    val safePrimeBytes = BigIntegerUtils.bigIntegerToBytes(safePrime)

    digest.reset()
    digest.update(safePrimeBytes)
    val hashedSafePrime = BigInteger(1, digest.digest())

    digest.reset()
    digest.update(leftPad(BigIntegerUtils.bigIntegerToBytes(generator), safePrimeBytes.size))
    val hashedGenerator = BigInteger(1, digest.digest())

    val hashedSafePrimeXorGenerator = hashedSafePrime.xor(hashedGenerator)

    digest.reset()
    digest.update(userId.toByteArray(Charsets.UTF_8))
    val hashedUserId = digest.digest()

    val hashedSessionKey = hashBigInteger(digest, sessionKey)

    digest.reset()
    digest.update(BigIntegerUtils.bigIntegerToBytes(hashedSafePrimeXorGenerator))
    digest.update(hashedUserId)
    digest.update(BigIntegerUtils.bigIntegerToBytes(salt))
    digest.update(BigIntegerUtils.bigIntegerToBytes(publicA))
    digest.update(BigIntegerUtils.bigIntegerToBytes(publicB))
    digest.update(hashedSessionKey)

    return BigIntegerUtils.bigIntegerFromBytes(digest.digest())
}

private fun hashBigInteger(digest: MessageDigest, value: BigInteger): ByteArray {
    digest.reset()
    digest.update(BigIntegerUtils.bigIntegerToBytes(value))

    return digest.digest()
}

private fun leftPad(bytes: ByteArray, length: Int): ByteArray {
    if (bytes.size >= length) return bytes
    val padded = ByteArray(length)
    System.arraycopy(bytes, 0, padded, length - bytes.size, bytes.size)

    return padded
}
