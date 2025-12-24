package app.cliq.backend.annotations

import app.cliq.backend.config.API_TOKEN_SECURITY_SCHEME_NAME
import app.cliq.backend.config.OIDC_SECURITY_SCHEME_NAME
import io.swagger.v3.oas.annotations.media.Content
import io.swagger.v3.oas.annotations.responses.ApiResponse
import io.swagger.v3.oas.annotations.security.SecurityRequirement
import io.swagger.v3.oas.annotations.security.SecurityRequirements
import org.springframework.security.access.prepost.PreAuthorize

// TODO:
//  - better error documentation

// Features
@PreAuthorize("isAuthenticated()")
@SecurityRequirements(
    SecurityRequirement(name = API_TOKEN_SECURITY_SCHEME_NAME),
    SecurityRequirement(name = OIDC_SECURITY_SCHEME_NAME),
)
@ApiResponse(responseCode = "401", description = "Unauthorized", content = [Content()])
@ApiResponse(responseCode = "403", description = "Forbidden", content = [Content()])
// Annotation config
@Target(AnnotationTarget.FUNCTION, AnnotationTarget.CLASS)
@Retention(AnnotationRetention.RUNTIME)
annotation class Authenticated
