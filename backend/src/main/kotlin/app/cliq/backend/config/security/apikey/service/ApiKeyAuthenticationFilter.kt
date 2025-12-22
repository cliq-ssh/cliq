package app.cliq.backend.config.security.apikey.service

import app.cliq.backend.config.security.apikey.ApiKeyAuthenticationConverter
import org.springframework.security.authentication.AuthenticationManager
import org.springframework.security.web.AuthenticationEntryPoint
import org.springframework.security.web.authentication.AuthenticationFilter

class ApiKeyAuthenticationFilter(
    authenticationManager: AuthenticationManager,
    apiKeyAuthenticationConverter: ApiKeyAuthenticationConverter,
    private val authenticationEntryPoint: AuthenticationEntryPoint,
) : AuthenticationFilter(
        authenticationManager,
        apiKeyAuthenticationConverter,
    ) {
    init {
        // We do this because the default success handler makes a redirect to '/'
        successHandler = { _, _, _ -> }

        // Beware, that AuthenticationEntryPoint, registered
        // via HttpSecurity DSL (and used by ExceptionTranslationFilter),
        // will NOT be invoked while handling authentication exceptions
        // thrown by the authentication manager inside this filter
        // because the AuthenticationFilter catches the exception
        // and does not rethrow it, so we need to implement a failure handler,
        // which, by the way, might simply rethrow an exception
        // to let it be handled by ExceptionTranslationFilter
        failureHandler = { req, res, ex ->
            authenticationEntryPoint.commence(req, res, ex)
        }
    }
}
