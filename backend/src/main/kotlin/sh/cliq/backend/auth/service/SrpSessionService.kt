package sh.cliq.backend.auth.service

import com.nimbusds.srp6.SRP6CryptoParams
import com.nimbusds.srp6.SRP6ServerSession
import org.springframework.cache.annotation.CacheEvict
import org.springframework.cache.annotation.Cacheable
import org.springframework.stereotype.Service
import sh.cliq.backend.auth.service.nimbus.Rfc5054AppendixBClientEvidenceRoutine
import sh.cliq.backend.auth.service.nimbus.Rfc5054AppendixBServerEvidenceRoutine

@Service
class SrpSessionService {
    @Suppress("UnusedParameter")
    @Cacheable(cacheNames = [AUTHENTICATION_SESSION_CACHE_NAME], key = "#key")
    fun getOrCreateAuthenticationSession(key: String, params: SRP6CryptoParams): SRP6ServerSession {
        val session = SRP6ServerSession(params)

        session.setClientEvidenceRoutine(Rfc5054AppendixBClientEvidenceRoutine)
        session.setServerEvidenceRoutine(Rfc5054AppendixBServerEvidenceRoutine)

        return session
    }

    // We need to suppress EmptyFunctionBlock here because the function is used only for its annotation and doesn't need
    // to do anything.
    @Suppress("EmptyFunctionBlock", "UnusedParameter")
    @CacheEvict(cacheNames = [AUTHENTICATION_SESSION_CACHE_NAME], key = "#key")
    fun evictAuthenticationSession(key: String) {
    }
}
