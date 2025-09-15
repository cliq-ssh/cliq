package app.cliq.backend.session

import app.cliq.backend.config.API_TOKEN_SECURITY_SCHEME_NAME
import io.swagger.v3.oas.annotations.media.Content
import io.swagger.v3.oas.annotations.responses.ApiResponse
import io.swagger.v3.oas.annotations.security.SecurityRequirement
import org.springframework.security.access.prepost.PreAuthorize

// TODO:
//  - better error documentation

// Features
@PreAuthorize("isAuthenticated()")
@SecurityRequirement(name = API_TOKEN_SECURITY_SCHEME_NAME)
@ApiResponse(responseCode = "401", description = "Unauthorized", content = [Content()])
@ApiResponse(responseCode = "403", description = "Forbidden", content = [Content()])
// Annotation config
@Target(AnnotationTarget.FUNCTION, AnnotationTarget.CLASS)
@Retention(AnnotationRetention.RUNTIME)
annotation class Authenticated
