import dev.detekt.gradle.Detekt
import dev.detekt.gradle.DetektCreateBaselineTask

plugins {
    val kotlinVersion = "2.3.20"
    // Kotlin
    kotlin("jvm") version kotlinVersion
    kotlin("plugin.spring") version kotlinVersion
    kotlin("plugin.jpa") version kotlinVersion
    kotlin("plugin.allopen") version kotlinVersion

    // Spring / Spring Boot
    id("org.springframework.boot") version "4.0.5"
    id("io.spring.dependency-management") version "1.1.7"

    // Linter and Formatter
    id("dev.detekt") version "2.0.0-alpha.2"
}

// Fixes: https://github.com/detekt/detekt/issues/6198
// Run detekt with the latest supported kotlin version
dependencyManagement {
    configurations.matching { it.name == "detekt" }.all {
        resolutionStrategy.eachDependency {
            if (requested.group == "org.jetbrains.kotlin") {
                useVersion(dev.detekt.gradle.plugin.getSupportedKotlinVersion())
            }
        }
    }
}

group = "app.cliq"
version = "0.1.0"
description = "Open source SSH & SFTP client with focus on security and portability"

val targetJvmVersion = 25

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(targetJvmVersion)
    }
}

kotlin {
    compilerOptions.freeCompilerArgs.add("-Xannotation-default-target=param-property")
    jvmToolchain(targetJvmVersion)
}

configurations {
    compileOnly {
        extendsFrom(configurations.annotationProcessor.get())
    }
}

detekt {
    buildUponDefaultConfig = true
    allRules = false
    autoCorrect = false // For CI/CD. Locally use the `--auto-correct` flag
    config.setFrom("$projectDir/config/detekt.yaml")
// Following lines should be used when customization is needed for detekt
//    baseline = file("$projectDir/config/baseline.xml")
}

repositories {
    mavenCentral()
}

dependencies {
    // Web Framework
    implementation("org.springframework.boot:spring-boot-starter-webmvc")
    implementation("org.springframework.boot:spring-boot-starter-actuator")

    // Rate limiting
    val bucket4JVersion = "8.18.0"
    implementation("com.bucket4j:bucket4j_jdk17-core:$bucket4JVersion")
    implementation("com.bucket4j:bucket4j_jdk17-caffeine:$bucket4JVersion")

    // Caching
    implementation("org.springframework.boot:spring-boot-starter-cache")
    implementation("com.github.ben-manes.caffeine:caffeine")

    // JPA/SQL
    implementation("org.springframework.boot:spring-boot-starter-data-jpa")
    runtimeOnly("org.postgresql:postgresql")
    // Flyway
    val flywayVersion = "12.4.0"
    implementation("org.springframework.boot:spring-boot-starter-flyway")
    implementation("org.flywaydb:flyway-core:$flywayVersion")
    implementation("org.flywaydb:flyway-database-postgresql:$flywayVersion")

    // Security
    implementation("org.springframework.boot:spring-boot-starter-security")
    // OIDC
    implementation("org.springframework.boot:spring-boot-starter-oauth2-client")
    // SRP
    implementation("com.nimbusds:srp6a:2.1.0")

    // Algorithm Provider & Encryption primitives
    implementation("org.bouncycastle:bcprov-jdk18on:1.84")

    // Serialization
    implementation("org.springframework.boot:spring-boot-starter-jackson")
    implementation("tools.jackson.module:jackson-module-kotlin")

    // E-Mail
    implementation("org.springframework.boot:spring-boot-starter-mail")
    implementation("io.pebbletemplates:pebble-spring-boot-starter:4.1.1")

    // Validation
    implementation("org.springframework.boot:spring-boot-starter-validation")

    // OpenAPI
    val springdocVersion = "3.0.3"
    implementation("org.springdoc:springdoc-openapi-starter-webmvc-api:$springdocVersion")
    implementation("org.springdoc:springdoc-openapi-starter-webmvc-ui:$springdocVersion")
    implementation("org.springdoc:springdoc-openapi-starter-webmvc-scalar:$springdocVersion")

    // Annotations
    annotationProcessor("org.springframework.boot:spring-boot-configuration-processor")

    // Kotlin specifics
    implementation("org.jetbrains.kotlin:kotlin-reflect")

    // IO-Utils
    implementation("commons-io:commons-io:2.22.0")

    // Testing //

    // Junit 5
    testImplementation("org.jetbrains.kotlin:kotlin-test-junit5")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")

    // Spring
    testImplementation("org.springframework.boot:spring-boot-webmvc-test")

    // Security
    testImplementation("org.springframework.boot:spring-boot-starter-security-test")

    // JPA/SQL
    testImplementation("org.springframework.boot:spring-boot-starter-data-jpa-test")

    // Greenmail
    val greenmailVersion = "2.1.8"
    testImplementation("com.icegreen:greenmail-spring:$greenmailVersion")
    testImplementation("com.icegreen:greenmail:$greenmailVersion")
    testImplementation("com.icegreen:greenmail-junit5:$greenmailVersion")

    // Mail commons
    testImplementation("org.apache.commons:commons-email2-jakarta:2.0.0-M1")

    // Mockito
    testImplementation("org.mockito:mockito-core:5.23.0")
    testImplementation("org.mockito:mockito-junit-jupiter:5.23.0")
    testImplementation("org.mockito.kotlin:mockito-kotlin:6.3.0")

    // AssertJ
    testImplementation("org.assertj:assertj-core:3.27.7")

    // Kotlin specifics
    testImplementation("org.awaitility:awaitility-kotlin:4.3.0")

    // Linting

    // Detekt
    detektPlugins("dev.detekt:detekt-rules-ktlint-wrapper:2.0.0-alpha.2")
}

kotlin {
    compilerOptions {
        freeCompilerArgs.addAll("-Xjsr305=strict")
    }
}

allOpen {
    annotation("jakarta.persistence.Entity")
    annotation("jakarta.persistence.MappedSuperclass")
    annotation("jakarta.persistence.Embeddable")
}

tasks.withType<Test> {
    useJUnitPlatform()

    doFirst {
        jvmArgs("-javaagent:${classpath.filter { it.name.contains("byte-buddy-agent") }.asPath}")
    }

    reports {
        junitXml.required.set(true)
        html.required.set(true)
    }

    testLogging {
        events("passed", "skipped", "failed")
        showStandardStreams = false
    }

    ignoreFailures = true
    systemProperty("file.encoding", "UTF-8")
}

tasks.withType<JavaCompile> {
    options.encoding = "UTF-8"
}

tasks.withType<Detekt>().configureEach {
    reports {
        html.required.set(true) // observe findings in your browser with structure and code snippets
        sarif.required.set(true) // standardized SARIF format (https://sarifweb.azurewebsites.net/) to support integrations with GitHub Code Scanning
        markdown.required.set(true) // simple Markdown format
    }
}

tasks.withType<Detekt>().configureEach {
    jvmTarget = targetJvmVersion.toString()
}

tasks.withType<DetektCreateBaselineTask>().configureEach {
    jvmTarget = targetJvmVersion.toString()
}

// tasks.withType<ProcessResources> {
//    filesMatching("application.yaml") {
//        expand(project.properties)
//    }
// }

tasks.processResources {
    // We don't pass all project properties to compatible with gradles configuration cache
    val expandProps = mapOf(
        "rootProject" to mapOf("name" to rootProject.name),
        "version" to project.version.toString(),
        "description" to (project.description)
    )

    // work around IDEA-296490
    // use above when fixed
    duplicatesStrategy = DuplicatesStrategy.INCLUDE
    with(
        copySpec {
            from("src/main/resources/application.yaml") {
                expand(expandProps)
            }
        },
    )
}
