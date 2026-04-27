package app.cliq.backend.config.feature

const val FEATURE_OIDC_PROPERTY_NAME = "app.oidc.enabled"

enum class Features(val property: String) {
    OIDC(FEATURE_OIDC_PROPERTY_NAME),
}
