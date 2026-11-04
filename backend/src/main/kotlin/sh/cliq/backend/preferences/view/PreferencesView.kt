package sh.cliq.backend.preferences.view

import io.swagger.v3.oas.annotations.media.Schema
import sh.cliq.backend.preferences.entity.Preferences
import java.time.OffsetDateTime

@Schema
data class PreferencesView(
    val preferences: String,
    val version: String,
    val updatedAt: OffsetDateTime,
    val createdAt: OffsetDateTime,
) {
    companion object {
        fun fromPreferences(preferences: Preferences): PreferencesView = PreferencesView(
            preferences = preferences.encryptedPreferences,
            version = preferences.version,
            updatedAt = preferences.updatedAt,
            createdAt = preferences.createdAt,
        )
    }
}
