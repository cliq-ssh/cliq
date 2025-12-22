package app.cliq.backend.auth

class PasswordHashWrapper(
    val hash: String,
) {
    override fun toString(): String = "[PROTECTED] PasswordHashWrapper"
}
