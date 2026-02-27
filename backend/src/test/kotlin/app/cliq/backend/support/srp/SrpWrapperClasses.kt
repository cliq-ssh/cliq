package app.cliq.backend.support.srp

import java.math.BigInteger

data class SrpData(
    val salt: Salt,
    val verifier: Verifier,
)

data class Salt(
    val salt: ByteArray,
    val asBigInteger: BigInteger,
    val encoded: String,
)

data class Verifier(
    val verifier: BigInteger,
    val encoded: String,
)
