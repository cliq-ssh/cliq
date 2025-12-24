package app.cliq.backend.user

import app.cliq.backend.annotations.Authenticated
import app.cliq.backend.auth.AuthUser
import io.swagger.v3.oas.annotations.Operation
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

@RestController("/api/test")
class TestController {
    @Authenticated
    @GetMapping
    @Operation(summary = "Test authenticated endpoint")
    fun testAuthenticated(
        @AuthenticationPrincipal user: AuthUser,
    ): String = "Hello ${user.email}"

    @GetMapping("/public")
    @Operation(summary = "Test public endpoint")
    fun publicEndpoint(): String = "Hello, World!"
}
