package app.cliq.backend.auth.view

import app.cliq.backend.docs.EXAMPLE_DATETIME
import app.cliq.backend.docs.EXAMPLE_SESSION_ID
import app.cliq.backend.docs.EXAMPLE_SESSION_NAME
import io.swagger.v3.oas.annotations.media.Schema
import java.time.OffsetDateTime

@Schema
open class SessionResponse(
    @field:Schema(example = EXAMPLE_SESSION_ID)
    val id: Long,
    @field:Schema(example = EXAMPLE_SESSION_NAME)
    val name: String? = null,
    @field:Schema(example = EXAMPLE_DATETIME)
    val lastUsedAt: OffsetDateTime? = null,
    @field:Schema(example = EXAMPLE_DATETIME)
    val expiresAt: OffsetDateTime,
    @field:Schema(example = EXAMPLE_DATETIME)
    val createdAt: OffsetDateTime,
)
