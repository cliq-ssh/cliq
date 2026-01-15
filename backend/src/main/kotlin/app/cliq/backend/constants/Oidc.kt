package app.cliq.backend.constants

object Oidc {
    const val AUTHORIZATION_ENDPOINT = "/oauth2/authorization/oidc"
    const val CALLBACK_ENDPOINT = "/login/oauth2/code/oidc"
    const val BACK_CHANNEL_LOGOUT_ENDPOINT = "/logout/connect/back-channel/oidc"
}
