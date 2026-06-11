package app.cliq.backend.user.service

import app.cliq.backend.user.User
import app.cliq.backend.user.UserRepository
import app.cliq.backend.user.factory.UserFactory
import org.springframework.security.oauth2.core.oidc.user.OidcUser
import org.springframework.stereotype.Service

@Service
class UserOidcService(private val userRepository: UserRepository, private val userFactory: UserFactory) {
    fun putUserFromOidcUser(oidcUser: OidcUser): User {
        val sub = oidcUser.subject ?: throw IllegalArgumentException("OIDC User must have a subject")
        var user = userRepository.findByOidcSub(sub)
        user =
            when (user) {
                null -> linkOrCreateUser(oidcUser)
                else -> updateUser(user, oidcUser)
            }

        return userRepository.save(user)
    }

    private fun updateUser(user: User, oidcUser: OidcUser): User {
        user.name = oidcUser.preferredUsername ?: throw IllegalArgumentException(
            "OIDC User must have a preferredUsername",
        )
        user.email = oidcUser.email ?: throw IllegalArgumentException("OIDC User must have a email")

        return user
    }

    private fun linkOrCreateUser(oidcUser: OidcUser): User {
        val email = oidcUser.email ?: throw IllegalArgumentException("OIDC User must have an email")

        return when (val user = userRepository.findByEmail(email)) {
            null -> {
                createOidcUser(oidcUser)
            }

            else -> {
                linkUser(oidcUser, user)
                user
            }
        }
    }

    private fun linkUser(oidcUser: OidcUser, user: User) {
        user.oidcSub = oidcUser.subject
    }

    private fun createOidcUser(oidcUser: OidcUser): User {
        val email = oidcUser.email ?: throw IllegalArgumentException("OIDC User must have an email")
        val sub = oidcUser.subject ?: throw IllegalArgumentException("OIDC User must have a subject")
        val preferredUsername = oidcUser.preferredUsername ?: throw IllegalArgumentException(
            "OIDC User must have a preferredUsername",
        )

        return userFactory.createOidcUser(
            email = email,
            sub = sub,
            name = preferredUsername,
        )
    }
}
