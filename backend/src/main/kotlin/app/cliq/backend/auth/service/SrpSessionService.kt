package app.cliq.backend.auth.service

import com.nimbusds.srp6.SRP6CryptoParams
import com.nimbusds.srp6.SRP6ServerSession
import org.springframework.cache.annotation.CacheEvict
import org.springframework.cache.annotation.Cacheable
import org.springframework.stereotype.Service

@Service
class SrpSessionService {
    @Suppress("UnusedParameter")
    @Cacheable(cacheNames = [AUTHENTICATION_SESSION_CACHE_NAME], key = "#key")
    fun getOrCreateAuthenticationSession(key: String, params: SRP6CryptoParams): SRP6ServerSession =
        SRP6ServerSession(params)

    // We need to suppress EmptyFunctionBlock here because the function is used only for its annotation and doesn't need
    // to do anything.
    @Suppress("EmptyFunctionBlock", "UnusedParameter")
    @CacheEvict(cacheNames = [AUTHENTICATION_SESSION_CACHE_NAME], key = "#key")
    fun evictAuthenticationSession(key: String) {
    }
}
