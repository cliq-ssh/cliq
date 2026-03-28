package app.cliq.backend.config.messagesource

import org.apache.commons.io.input.ReaderInputStream
import org.springframework.beans.factory.config.YamlPropertiesFactoryBean
import org.springframework.core.io.InputStreamResource
import org.springframework.util.PropertiesPersister
import java.io.IOException
import java.io.InputStream
import java.io.OutputStream
import java.io.Reader
import java.io.UnsupportedEncodingException
import java.io.Writer
import java.util.Properties

class YamlPropertiesLoader : PropertiesPersister {
    override fun load(props: Properties, inputStream: InputStream) {
        val yaml = YamlPropertiesFactoryBean()
        yaml.setResources(InputStreamResource(inputStream))
        val yamlObject =
            yaml.getObject() ?: throw IOException("Failed to load YAML properties: No data found in the input stream.")

        props.putAll(yamlObject)
    }

    @Throws(IOException::class)
    override fun load(props: Properties, reader: Reader) {
        // Uses Commons IO ReaderInputStream
        val inputStream: InputStream = ReaderInputStream.builder().setReader(reader).get()
        load(props, inputStream)
    }

    @Throws(IOException::class)
    override fun store(props: Properties, outputStream: OutputStream, header: String): Unit =
        throw UnsupportedEncodingException("Storing is not supported by YamlPropertiesLoader")

    @Throws(IOException::class)
    override fun store(props: Properties, writer: Writer, header: String): Unit =
        throw UnsupportedEncodingException("Storing is not supported by YamlPropertiesLoader")

    @Throws(IOException::class)
    override fun loadFromXml(props: Properties, inputStream: InputStream): Unit =
        throw UnsupportedEncodingException("Loading from XML is not supported by YamlPropertiesLoader")

    @Throws(IOException::class)
    override fun storeToXml(props: Properties, outputStream: OutputStream, header: String): Unit =
        throw UnsupportedEncodingException("Storing to XML is not supported by YamlPropertiesLoader")

    @Throws(IOException::class)
    override fun storeToXml(props: Properties, outputStream: OutputStream, header: String, encoding: String): Unit =
        throw UnsupportedEncodingException("Storing to XML is not supported by YamlPropertiesLoader")
}
