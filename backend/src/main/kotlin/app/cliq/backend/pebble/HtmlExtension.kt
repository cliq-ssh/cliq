package app.cliq.backend.pebble

import io.pebbletemplates.pebble.extension.AbstractExtension
import io.pebbletemplates.pebble.extension.Filter
import io.pebbletemplates.pebble.template.EvaluationContext
import io.pebbletemplates.pebble.template.PebbleTemplate

class HtmlExtension : AbstractExtension() {
    override fun getFilters(): Map<String, Filter> {
        val filters = HashMap<String, Filter>()
        if (super.filters != null) {
            filters.putAll(super.filters!!)
        }

        filters["nl2br"] = Nl2BrFilter()

        return filters
    }
}

class Nl2BrFilter : Filter {
    private val newlineRegex = Regex("(\r\n|\r|\n)")

    override fun apply(
        input: Any?,
        args: Map<String?, Any?>?,
        self: PebbleTemplate?,
        context: EvaluationContext?,
        lineNumber: Int,
    ): Any? {
        if (input == null) {
            return null
        }
        if (input !is String) {
            throw IllegalArgumentException("nl2br filter only supports String input")
        }

        return input.replace(newlineRegex, "<br>")
    }

    override fun getArgumentNames(): List<String?>? = null
}
