package app.cliq.backend.user.view

import app.cliq.backend.docs.EXAMPLE_DATETIME
import app.cliq.backend.docs.EXAMPLE_EMAIL
import app.cliq.backend.docs.EXAMPLE_USERNAME
import app.cliq.backend.docs.EXAMPLE_USER_ID
import app.cliq.backend.user.User
import io.swagger.v3.oas.annotations.media.Schema
import java.io.Serializable
import java.time.OffsetDateTime

@Schema
class UserResponse(
    @field:Schema(example = EXAMPLE_USER_ID)
    val id: Long,
    @field:Schema(example = EXAMPLE_EMAIL)
    val email: String,
    @field:Schema(example = EXAMPLE_USERNAME)
    val username: String,
    @field:Schema(example = EXAMPLE_DATETIME)
    val createdAt: OffsetDateTime,
    @field:Schema(example = EXAMPLE_DATETIME)
    val updatedAt: OffsetDateTime? = null,
) : Serializable {
    companion object {
        fun fromUser(user: User): UserResponse =
            UserResponse(
                id = user.id!!,
                email = user.email,
                username = user.name,
                createdAt = user.createdAt,
                updatedAt = user.updatedAt,
            )
    }
}
