package app.cliq.backend.user.view

import app.cliq.backend.user.User
import io.swagger.v3.oas.annotations.media.Schema
import java.io.Serializable
import java.time.OffsetDateTime

@Schema
class UserResponse(
    @field:Schema(example = "178939097090359300")
    val id: Long,
    @field:Schema(example = "user@example.lan")
    val email: String,
    @field:Schema(example = "John Doe")
    val name: String,
    @field:Schema(example = "2025-05-22T12:31:28.274923603+02:00")
    val createdAt: OffsetDateTime,
) : Serializable {
    companion object {
        fun fromUser(user: User): UserResponse =
            UserResponse(
                id = user.id,
                email = user.email,
                name = user.name,
                createdAt = user.createdAt,
            )
    }
}
