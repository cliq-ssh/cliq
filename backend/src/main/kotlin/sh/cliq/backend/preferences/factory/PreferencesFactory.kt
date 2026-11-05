package sh.cliq.backend.preferences.factory

import org.springframework.stereotype.Service
import sh.cliq.backend.preferences.entity.Preferences
import sh.cliq.backend.preferences.params.PreferencesPutParams
import sh.cliq.backend.user.User
import java.time.Clock
import java.time.OffsetDateTime

@Service
class PreferencesFactory(private val clock: Clock) {
    fun createFromPutParams(user: User, preferencesPutParams: PreferencesPutParams): Preferences =
        create(user, preferencesPutParams.preferences, preferencesPutParams.version)

    fun updateFromPutParams(existingPreferences: Preferences, preferencesPutParams: PreferencesPutParams): Preferences {
        existingPreferences.encryptedPreferences = preferencesPutParams.preferences
        existingPreferences.version = preferencesPutParams.version

        return existingPreferences
    }

    fun create(user: User, encryptedPreferences: String, version: String): Preferences = Preferences(
        user = user,
        encryptedPreferences = encryptedPreferences,
        version = version,
        createdAt = OffsetDateTime.now(clock),
        updatedAt = OffsetDateTime.now(clock),
    )
}
