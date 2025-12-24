package app.cliq.backend.config.security.oidc

import app.cliq.backend.user.UserOidcService
import org.springframework.core.convert.converter.Converter
import org.springframework.security.authentication.AbstractAuthenticationToken
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken
import org.springframework.security.oauth2.server.resource.authentication.JwtGrantedAuthoritiesConverter
import org.springframework.stereotype.Service

@Service
class OidcAuthenticationConverter(
    private val userOidcService: UserOidcService,
) : Converter<Jwt, AbstractAuthenticationToken> {
    private val authoritiesConverter = JwtGrantedAuthoritiesConverter()

    override fun convert(source: Jwt): AbstractAuthenticationToken {
        // ensure a local user exists / is updated
        val email = source.claims["email"] as String
        userOidcService.putUserFromJwt(source, email)

        val authorities = authoritiesConverter.convert(source) ?: emptyList()

        return JwtAuthenticationToken(source, authorities)
    }
}
