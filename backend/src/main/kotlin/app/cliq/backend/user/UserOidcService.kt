package app.cliq.backend.user

import app.cliq.backend.user.factory.UserFactory
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.stereotype.Service

@Service
class UserOidcService(
    private val userRepository: UserRepository,
    private val userFactory: UserFactory,
) {
    fun putUserFromJwt(
        jwt: Jwt,
        email: String,
    ): User {
        val sub = jwt.subject
        var user = userRepository.findUserByOidcSub(sub)
        user = user ?: linkOrCreateUser(jwt, email)

        return userRepository.save(user)
    }

    private fun linkOrCreateUser(
        jwt: Jwt,
        email: String,
    ): User {
        val user = userRepository.findUserByEmail(email)
        return when (user) {
            null -> {
                createOidcUser(jwt, email)
            }

            else -> {
                linkUser(jwt, user)
                user
            }
        }
    }

    private fun linkUser(
        jwt: Jwt,
        user: User,
    ) {
        user.oidcSub = jwt.subject
    }

    private fun createOidcUser(
        jwt: Jwt,
        email: String,
    ): User {
        val name = jwt.getClaimAsString("name") ?: jwt.getClaimAsString("preferred_username")
        return userFactory.createOidcUser(
            email = email,
            sub = jwt.subject,
            name = name,
        )
    }
}
