package app.cliq.backend.auth.service

import com.nimbusds.srp6.SRP6CryptoParams
import com.nimbusds.srp6.SRP6ServerSession
import org.springframework.cache.annotation.CacheEvict
import org.springframework.cache.annotation.Cacheable
import org.springframework.stereotype.Service

@Service
class SrpSessionService {
    @Cacheable(cacheNames = [AUTHENTICATION_SESSION_CACHE_NAME], key = "#key")
    fun getOrCreateAuthenticationSession(
        key: String,
        params: SRP6CryptoParams,
    ): SRP6ServerSession = SRP6ServerSession(params)

    @CacheEvict(cacheNames = [AUTHENTICATION_SESSION_CACHE_NAME], key = "#key")
    fun evictAuthenticationSession(key: String) {}
}
