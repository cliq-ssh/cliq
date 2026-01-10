package app.cliq.backend.config.security.exception.handler

import app.cliq.backend.error.ErrorResponse
import app.cliq.backend.shared.HttpUtils
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.slf4j.LoggerFactory
import org.springframework.security.core.AuthenticationException
import org.springframework.security.web.AuthenticationEntryPoint
import org.springframework.stereotype.Component

@Component
class ApplicationAuthenticationEntryPoint(
    private val httpUtils: HttpUtils,
) : AuthenticationEntryPoint {
    private val logger = LoggerFactory.getLogger(this::class.java)

    override fun commence(
        request: HttpServletRequest,
        response: HttpServletResponse,
        authException: AuthenticationException,
    ) {
        logger.warn("Unauthorized access attempt", authException)

        val error = ErrorResponse.fromAuthenticationException(authException)
        httpUtils.setErrorResponse(response, error)
    }
}
