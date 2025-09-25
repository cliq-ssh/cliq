package app.cliq.backend.support

import jakarta.persistence.Entity
import jakarta.persistence.EntityManager
import jakarta.persistence.Table
import jakarta.persistence.metamodel.ManagedType
import jakarta.persistence.metamodel.Metamodel
import jakarta.transaction.Transactional
import org.springframework.beans.factory.InitializingBean
import org.springframework.boot.test.context.TestComponent
import java.util.Locale
import kotlin.reflect.full.findAnnotation

@TestComponent
class DatabaseCleanupService(
    private val entityManager: EntityManager,
) : InitializingBean {
    private lateinit var joinedTableNames: String
    private val toSnakeRegex = "(?<=[a-zA-Z])[A-Z]".toRegex()

    // Set table names to be truncated on init of bean
    override fun afterPropertiesSet() {
        val tableNames = getManagedTableNames()
            .filter { it != "instances" }

        joinedTableNames = tableNames.joinToString(separator = ",")
    }

    // Resolve table names from all managed types that have either a @Table or @Entity annotation defined
    private fun getManagedTableNames(): List<String> {
        val metaModel: Metamodel = entityManager.metamodel
        return metaModel.managedTypes
            .filter {
                val kotlinClass = it.javaType.kotlin
                kotlinClass.findAnnotation<Table>() != null ||
                    kotlinClass.findAnnotation<Entity>() != null
            }
            .map {
                val annotationName = getAnnotationName(it)
                getTableName(annotationName, it.javaType.simpleName)
            }
    }

    // Get name from managed type
    // @Table is optional, @Entity is a mandatory annotation for every defined entity (hence the !!)
    private fun getAnnotationName(managedType: ManagedType<*>): String {
        val kotlinClass = managedType.javaType.kotlin
        return kotlinClass.findAnnotation<Table>()?.name
            ?: kotlinClass.findAnnotation<Entity>()!!.name
    }

    // Either get the name defined in the annotation and otherwise convert the java type to the default naming strategy (snake case)
    private fun getTableName(annotationName: String, javaTypeName: String): String {
        return if (annotationName == "") {
            camelToSnakeCase(javaTypeName)
        } else {
            annotationName
        }
    }

    // Inspired from: https://stackoverflow.com/a/60010299
    private fun camelToSnakeCase(camelString: String): String {
        return toSnakeRegex.replace(camelString) {
            "_${it.value}"
        }.lowercase(Locale.getDefault())
    }

    @Transactional
    fun truncate() {
        entityManager
            .createNativeQuery("TRUNCATE TABLE $joinedTableNames CASCADE;")
            .executeUpdate()
    }

    @Transactional
    fun truncateInstances() {
        entityManager
            .createNativeQuery("TRUNCATE TABLE instances CASCADE;")
            .executeUpdate()
    }
}
