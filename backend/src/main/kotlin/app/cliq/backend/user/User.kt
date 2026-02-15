package app.cliq.backend.user

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import jakarta.persistence.Table
import jakarta.persistence.UniqueConstraint
import java.time.OffsetDateTime

const val DEFAULT_LOCALE = "en"
const val UNVERIFIED_USER_INTERVAL_MINUTES = 60L * 24L // 1 day
const val PASSWORD_RESET_TOKEN_INTERVAL_MINUTES = 30L // 30 minutes

@Entity
@Table(
    name = "users",
    uniqueConstraints = [
        UniqueConstraint(columnNames = ["email", "email_verification_token"]),
        UniqueConstraint(columnNames = ["email", "reset_token"]),
    ],
)
class User(
    @Column(nullable = false, unique = true) var email: String,
    @Column(nullable = false) var name: String,
    @Column(nullable = false) var locale: String = DEFAULT_LOCALE,
    var resetToken: String? = null,
    var resetSentAt: OffsetDateTime? = null,
    var emailVerificationToken: String? = null,
    var emailVerificationSentAt: OffsetDateTime? = null,
    var emailVerifiedAt: OffsetDateTime? = null,
    @Column(nullable = false) var createdAt: OffsetDateTime,
    @Column(nullable = false) var updatedAt: OffsetDateTime,
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long? = null,
    @Column(nullable = true, unique = true)
    var oidcSub: String? = null,
    @Column(nullable = true)
    var srpSalt: String? = null,
    @Column(nullable = true)
    var srpVerifier: String? = null,
    @Column(nullable = true)
    var dataEncryptionKey: String? = null,
) {
    fun isEmailVerified(): Boolean = null != emailVerifiedAt

    fun isEmailVerificationTokenValid(): Boolean = emailVerificationToken != null && !isEmailVerificationTokenExpired()

    fun isEmailVerificationTokenExpired(): Boolean =
        !(
            emailVerificationSentAt != null &&
                emailVerificationSentAt!!.isAfter(
                    OffsetDateTime.now().minusMinutes(UNVERIFIED_USER_INTERVAL_MINUTES),
                )
        )

    fun isPasswordResetTokenExpired(): Boolean =
        resetToken != null && resetSentAt != null &&
            resetSentAt!!.isAfter(OffsetDateTime.now().minusMinutes(PASSWORD_RESET_TOKEN_INTERVAL_MINUTES))

    fun isUsable(): Boolean = isEmailVerified()

    override fun toString(): String = "User(id=$id)"
}
