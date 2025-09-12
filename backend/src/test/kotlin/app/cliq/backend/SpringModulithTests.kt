package app.cliq.backend

import org.junit.jupiter.api.Test
import org.springframework.modulith.core.ApplicationModules
import org.springframework.modulith.docs.Documenter

class SpringModulithTests {
    @Test
    fun writeDocumentationSnippets() {
        var modules = ApplicationModules.of(BackendApplication::class.java)

        modules = modules.verify()

        Documenter(modules)
            .writeModulesAsPlantUml()
            .writeIndividualModulesAsPlantUml()
    }
}
