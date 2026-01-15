package app.cliq.backend.acceptance.ratelimit

import app.cliq.backend.acceptance.AcceptanceTest
import app.cliq.backend.acceptance.AcceptanceTester
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.HttpHeaders
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import kotlin.test.assertContains

@AcceptanceTest
class RateLimiterTests(
    @Autowired private val mockMvc: MockMvc,
) : AcceptanceTester() {
    @Test
    fun `allows up to configured number of requests per minute`() {
        repeat(5) {
            mockMvc
                .perform(
                    MockMvcRequestBuilders.post("/api/auth/login").with {
                        it.remoteAddr = "1.2.3.4"
                        it
                    },
                ).andExpect(status().isBadRequest)
        }
    }

    @Test
    fun `blocks when rate limit exceeded`() {
        repeat(5) {
            mockMvc
                .perform(
                    MockMvcRequestBuilders.post("/api/auth/login").with {
                        it.remoteAddr = "5.6.7.8"
                        it
                    },
                ).andExpect(status().isBadRequest)
        }

        val result =
            mockMvc
                .perform(
                    MockMvcRequestBuilders.post("/api/auth/login").with {
                        it.remoteAddr = "5.6.7.8"
                        it
                    },
                ).andExpect(status().isTooManyRequests)
                .andReturn()

        assertContains(result.response.headerNames.toList(), HttpHeaders.RETRY_AFTER)
    }

    @Test
    fun `rate limiting is per ip`() {
        repeat(5) {
            mockMvc
                .perform(
                    MockMvcRequestBuilders.post("/api/auth/login").with {
                        it.remoteAddr = "10.0.0.1"
                        it
                    },
                ).andExpect(status().isBadRequest)
        }

        repeat(5) {
            mockMvc
                .perform(
                    MockMvcRequestBuilders.post("/api/auth/login").with {
                        it.remoteAddr = "10.0.0.2"
                        it
                    },
                ).andExpect(status().isBadRequest)
        }
    }
}
