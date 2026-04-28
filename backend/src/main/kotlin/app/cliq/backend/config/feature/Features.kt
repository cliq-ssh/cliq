package app.cliq.backend.config.feature

const val FEATURE_OIDC_PROPERTY_NAME = "app.oidc.enabled"
const val FEATURE_EMAIL_PROPERTY_NAME = "app.email.enabled"

enum class Features(val property: String) {
    OIDC(FEATURE_OIDC_PROPERTY_NAME),
    EMAIL(FEATURE_EMAIL_PROPERTY_NAME),
}
