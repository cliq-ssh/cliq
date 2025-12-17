package app.cliq.backend.user.service

import app.cliq.backend.user.UserRepository
import org.springframework.security.core.userdetails.User
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.security.core.userdetails.UserDetailsService
import org.springframework.security.core.userdetails.UsernameNotFoundException
import org.springframework.stereotype.Service

@Service
class LocalUserDetailService(
    private val userRepository: UserRepository,
) : UserDetailsService {
    override fun loadUserByUsername(username: String): UserDetails {
        val user = userRepository.findUserByEmail(username)
            ?: throw UsernameNotFoundException("User with email $username not found")

        return User.withUsername(user.email).password(user.password).build()
    }
}
