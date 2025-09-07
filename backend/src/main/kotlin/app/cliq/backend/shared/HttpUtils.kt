package app.cliq.backend.shared

import app.cliq.backend.error.ErrorResponse
import com.fasterxml.jackson.databind.ObjectMapper
import jakarta.servlet.http.HttpServletResponse
import org.springframework.stereotype.Service

const val CONTENT_TYPE_JSON = "application/json"
const val UTF8_ENCODING = "UTF-8"

@Service
class HttpUtils(
    private val objectMapper: ObjectMapper,
) {
    fun setErrorResponse(
        response: HttpServletResponse,
        errorResponse: ErrorResponse,
    ) {
        response.status = errorResponse.statusCode.value()
        response.contentType = CONTENT_TYPE_JSON
        response.characterEncoding = UTF8_ENCODING
        response.writer.write(objectMapper.writeValueAsString(errorResponse))
    }
}
