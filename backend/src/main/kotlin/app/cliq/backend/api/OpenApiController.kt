package app.cliq.backend.api

import io.swagger.v3.oas.annotations.Hidden
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.servlet.view.RedirectView

@RestController
@RequestMapping("/api")
class OpenApiController {
    @GetMapping
    @Hidden
    fun apiRedirect(): RedirectView = RedirectView("/api/scalar")
}
