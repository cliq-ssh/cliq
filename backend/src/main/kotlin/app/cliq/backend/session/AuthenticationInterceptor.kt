package app.cliq.backend.session

import app.cliq.backend.error.ApiException
import app.cliq.backend.error.ErrorResponse
import app.cliq.backend.exception.InvalidAuthTokenException
import app.cliq.backend.session.auth.BearerTokenAuthentication
import app.cliq.backend.session.event.SessionUsedEvent
import app.cliq.backend.shared.HttpUtils
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.slf4j.LoggerFactory
import org.springframework.context.ApplicationEventPublisher
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.stereotype.Component
import org.springframework.web.method.HandlerMethod
import org.springframework.web.servlet.HandlerInterceptor

private const val AUTHORIZATION_HEADER = "Authorization"
private const val BEARER_PREFIX = "Bearer "

@Component("authenticationInterceptor")
class AuthenticationInterceptor(
    private val sessionRepository: SessionRepository,
    private val eventPublisher: ApplicationEventPublisher,
    private val httpUtils: HttpUtils,
) : HandlerInterceptor {
    private val logger = LoggerFactory.getLogger(this::class.java)

    override fun preHandle(
        request: HttpServletRequest,
        response: HttpServletResponse,
        handler: Any,
    ): Boolean {
        if (handler !is HandlerMethod) {
            return true // Not a handler method, continue processing
        }

        val isAnnotated = handler.method.isAnnotationPresent(Authenticated::class.java)
        if (!isAnnotated) {
            return true // No authentication required for this method
        }

        val token = extractBearerToken(request)
        if (token == null) {
            val error = ErrorResponse.fromApiException(InvalidAuthTokenException())
            httpUtils.setErrorResponse(response, error)

            return false
        }

        try {
            val session = sessionRepository.findByApiKey(token) ?: throw InvalidAuthTokenException()
            val authentication = BearerTokenAuthentication(session, token, true)
            SecurityContextHolder.getContext().authentication = authentication

            eventPublisher.publishEvent(SessionUsedEvent(session.id!!))
        } catch (e: ApiException) {
            val error = ErrorResponse.fromApiException(e)
            httpUtils.setErrorResponse(response, error)

            return false
        } catch (e: Exception) {
            logger.error("Failed to authenticate with Bearer token", e)

            throw e
        }

        return true
    }

    private fun extractBearerToken(request: HttpServletRequest): String? {
        val header = request.getHeader(AUTHORIZATION_HEADER)
        return if (header?.startsWith(BEARER_PREFIX) == true) {
            header.removePrefix(BEARER_PREFIX)
        } else {
            null
        }
    }
}
