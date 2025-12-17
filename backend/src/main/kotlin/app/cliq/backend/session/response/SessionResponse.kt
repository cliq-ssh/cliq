package app.cliq.backend.session.response

import app.cliq.backend.session.Session
import io.swagger.v3.oas.annotations.media.Schema
import java.io.Serializable
import java.time.OffsetDateTime

@Schema
class SessionResponse(
    @field:Schema(example = "178939097090359300")
    val id: Long,
    val token: String,
    @field:Schema(example = "John Does Laptop")
    val name: String? = null,
    @field:Schema(example = "Fedora; Linux x86_64")
    val userAgent: String? = null,
    val createdAt: OffsetDateTime,
) : Serializable {
    companion object {
        fun fromSession(session: Session, token: String): SessionResponse =
            SessionResponse(
                session.id!!,
                token,
                session.name,
                session.userAgent,
                session.createdAt,
            )
    }
}
