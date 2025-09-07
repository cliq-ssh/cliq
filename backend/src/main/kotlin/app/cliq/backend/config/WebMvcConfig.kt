package app.cliq.backend.config

import app.cliq.backend.auth.AuthenticationInterceptor
import org.springframework.context.annotation.Configuration
import org.springframework.http.HttpStatus
import org.springframework.web.servlet.config.annotation.InterceptorRegistry
import org.springframework.web.servlet.config.annotation.ViewControllerRegistry
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer

@Configuration
class WebMvcConfig(
    private val authenticationInterceptor: AuthenticationInterceptor,
) : WebMvcConfigurer {
    override fun addInterceptors(registry: InterceptorRegistry) {
        super.addInterceptors(registry)

        registry.addInterceptor(authenticationInterceptor)
    }

    override fun addViewControllers(registry: ViewControllerRegistry) {
        super.addViewControllers(registry)
        registry.addRedirectViewController("/api", "/api/scalar").setStatusCode(HttpStatus.PERMANENT_REDIRECT)
    }
}
