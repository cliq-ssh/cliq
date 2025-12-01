package app.cliq.backend.user.annotation

import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.web.bind.annotation.RestController

@RestController
@Tag(name = "User", description = "User management")
annotation class UserController
