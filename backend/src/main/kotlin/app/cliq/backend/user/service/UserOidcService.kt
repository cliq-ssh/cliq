package app.cliq.backend.user.service

import app.cliq.backend.user.User
import app.cliq.backend.user.UserRepository
import app.cliq.backend.user.factory.UserFactory
import org.springframework.security.oauth2.core.oidc.user.OidcUser
import org.springframework.stereotype.Service

@Service
class UserOidcService(
    private val userRepository: UserRepository,
    private val userFactory: UserFactory,
) {
    fun putUserFromJwt(oidcUser: OidcUser): User {
        val sub = oidcUser.subject
        var user = userRepository.findByOidcSub(sub)
        user = user ?: linkOrCreateUser(oidcUser)

        return userRepository.save(user)
    }

    private fun linkOrCreateUser(oidcUser: OidcUser): User =
        when (val user = userRepository.findByEmail(oidcUser.email)) {
            null -> {
                createOidcUser(oidcUser)
            }

            else -> {
                linkUser(oidcUser, user)
                user
            }
        }

    private fun linkUser(
        oidcUser: OidcUser,
        user: User,
    ) {
        user.oidcSub = oidcUser.subject
    }

    private fun createOidcUser(oidcUser: OidcUser): User {
        val name = oidcUser.preferredUsername
        return userFactory.createOidcUser(
            email = oidcUser.email,
            sub = oidcUser.subject,
            name = name,
        )
    }
}
