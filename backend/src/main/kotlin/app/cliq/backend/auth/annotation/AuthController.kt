package app.cliq.backend.auth.annotation

import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.web.bind.annotation.RestController

@RestController
@Tag(
    name = "Authentication",
    description = "Endpoints related to user authentication and session management, including OAuth.",
)
annotation class AuthController
