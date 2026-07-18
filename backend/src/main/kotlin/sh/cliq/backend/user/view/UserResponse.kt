package sh.cliq.backend.user.view

import io.swagger.v3.oas.annotations.media.Schema
import sh.cliq.backend.constants.EXAMPLE_DATETIME
import sh.cliq.backend.constants.EXAMPLE_EMAIL
import sh.cliq.backend.constants.EXAMPLE_USERNAME
import sh.cliq.backend.constants.EXAMPLE_USER_ID
import sh.cliq.backend.user.User
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
) {
    companion object {
        fun fromUser(user: User): UserResponse = UserResponse(
            id = user.id!!,
            email = user.email,
            username = user.name,
            createdAt = user.createdAt,
            updatedAt = user.updatedAt,
        )
    }
}
