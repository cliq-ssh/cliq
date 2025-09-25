package app.cliq.backend.user.annotation

import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/v1/user")
@Tag(name = "User", description = "User management")
annotation class UserController
