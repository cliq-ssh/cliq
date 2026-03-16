package app.cliq.backend.annotations

import app.cliq.backend.config.JWT_SECURITY_SCHEME_NAME
import app.cliq.backend.config.OIDC_SECURITY_SCHEME_NAME
import app.cliq.backend.error.ApiException
import io.swagger.v3.oas.annotations.media.Content
import io.swagger.v3.oas.annotations.media.Schema
import io.swagger.v3.oas.annotations.responses.ApiResponse
import io.swagger.v3.oas.annotations.security.SecurityRequirement
import io.swagger.v3.oas.annotations.security.SecurityRequirements
import org.springframework.http.MediaType

// Features
@SecurityRequirements(
    SecurityRequirement(name = JWT_SECURITY_SCHEME_NAME),
    SecurityRequirement(name = OIDC_SECURITY_SCHEME_NAME),
)
@ApiResponse(
    responseCode = "401", description = "Unauthorized", content = [Content(
        mediaType = MediaType.APPLICATION_JSON_VALUE,
        schema = Schema(implementation = ApiException::class)
    )]
)
@ApiResponse(
    responseCode = "403", description = "Forbidden", content = [Content(
        mediaType = MediaType.APPLICATION_JSON_VALUE,
        schema = Schema(implementation = ApiException::class)
    )]
)
// Annotation config
@Target(AnnotationTarget.FUNCTION, AnnotationTarget.CLASS)
@Retention(AnnotationRetention.RUNTIME)
annotation class Authenticated
