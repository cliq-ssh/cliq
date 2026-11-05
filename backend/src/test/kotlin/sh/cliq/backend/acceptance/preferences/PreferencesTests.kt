package sh.cliq.backend.acceptance.preferences

import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.HttpHeaders
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import sh.cliq.backend.acceptance.AcceptanceTest
import sh.cliq.backend.acceptance.AcceptanceTester
import sh.cliq.backend.preferences.params.PreferencesPutParams
import sh.cliq.backend.preferences.view.PreferencesView
import sh.cliq.backend.support.UserCreationHelper
import tools.jackson.databind.ObjectMapper
import kotlin.test.assertEquals
import kotlin.test.assertNotNull

@AcceptanceTest
class PreferencesTests(
    @Autowired private val mockMvc: MockMvc,
    @Autowired private val objectMapper: ObjectMapper,
    @Autowired private val userCreationHelper: UserCreationHelper,
) : AcceptanceTester() {
    @Test
    fun `preferences endpoints require authentication`() {
        val params = PreferencesPutParams(preferences = "encrypted", version = "1")

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .put("/api/preferences")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(params)),
            ).andExpect(status().isUnauthorized)

        mockMvc
            .perform(MockMvcRequestBuilders.get("/api/preferences"))
            .andExpect(status().isUnauthorized)

        mockMvc
            .perform(MockMvcRequestBuilders.get("/api/preferences/last-updated"))
            .andExpect(status().isUnauthorized)
    }

    @Test
    fun `get returns not found when the user has no preferences`() {
        val authorization = authorizationHeader()

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .get("/api/preferences")
                    .header(HttpHeaders.AUTHORIZATION, authorization),
            ).andExpect(status().isNotFound)
    }

    @Test
    fun `put creates preferences and get returns them`() {
        val authorization = authorizationHeader()
        val params = PreferencesPutParams(preferences = "encrypted-preferences", version = "1")

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .put("/api/preferences")
                    .header(HttpHeaders.AUTHORIZATION, authorization)
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(params)),
            ).andExpect(status().isOk)

        val result =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .get("/api/preferences")
                        .header(HttpHeaders.AUTHORIZATION, authorization),
                ).andExpect(status().isOk)
                .andReturn()

        val response = objectMapper.readValue(result.response.contentAsString, PreferencesView::class.java)
        assertEquals(params.preferences, response.preferences)
        assertEquals(params.version, response.version)
        assertNotNull(response.createdAt)
        assertNotNull(response.updatedAt)

        val updatedAt =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .get("/api/preferences/last-updated")
                        .header(HttpHeaders.AUTHORIZATION, authorization),
                ).andExpect(status().isOk)
                .andReturn()
                .response
                .contentAsString
        assertEquals(response.updatedAt.toString(), updatedAt)
    }

    @Test
    fun `put updates existing preferences`() {
        val authorization = authorizationHeader()
        val initialParams = PreferencesPutParams(preferences = "initial", version = "1")
        val updatedParams = PreferencesPutParams(preferences = "updated", version = "2")

        putPreferences(initialParams, authorization)
        putPreferences(updatedParams, authorization)

        val result =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .get("/api/preferences")
                        .header(HttpHeaders.AUTHORIZATION, authorization),
                ).andExpect(status().isOk)
                .andReturn()

        val response = objectMapper.readValue(result.response.contentAsString, PreferencesView::class.java)
        assertEquals(updatedParams.preferences, response.preferences)
        assertEquals(updatedParams.version, response.version)
    }

    private fun authorizationHeader(): String {
        val tokenPair = userCreationHelper.createRandomAuthenticatedUser().tokenPair
        return "Bearer ${tokenPair.jwt.tokenValue}"
    }

    private fun putPreferences(params: PreferencesPutParams, authorization: String) {
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .put("/api/preferences")
                    .header(HttpHeaders.AUTHORIZATION, authorization)
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(params)),
            ).andExpect(status().isOk)
    }
}
