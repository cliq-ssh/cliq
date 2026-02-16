plugins {
    // Kotlin
    kotlin("jvm") version "2.3.10"
    kotlin("plugin.spring") version "2.3.10"
    kotlin("plugin.jpa") version "2.3.10"
    kotlin("plugin.allopen") version "2.3.10"

    // Spring / Spring Boot
    id("org.springframework.boot") version "4.0.2"
    id("io.spring.dependency-management") version "1.1.7"

    // Database Migrations
    id("org.flywaydb.flyway") version "12.0.1"

    // Linter and Formatter
    id("org.jlleitschuh.gradle.ktlint") version "14.0.1"
    id("com.autonomousapps.dependency-analysis") version "3.5.1"
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

flyway {
    url = "jdbc:postgresql://localhost:5432/cliq"
    user = "cliq"
    password = "cliq"
}

ktlint {
    version.set("1.8.0")
    android.set(false)
    ignoreFailures.set(false)
    reporters {
        reporter(org.jlleitschuh.gradle.ktlint.reporter.ReporterType.PLAIN)
        reporter(org.jlleitschuh.gradle.ktlint.reporter.ReporterType.CHECKSTYLE)
    }
    filter {
        exclude("**/generated/**")
        include("**/kotlin/**")
    }
}

dependencyAnalysis {
    issues {
        all {
            onAny {
                severity("fail")
            }
        }
    }
}

repositories {
    mavenCentral()
}

buildscript {
    dependencies {
        classpath("org.flywaydb:flyway-database-postgresql:12.0.1")
    }
}

dependencies {
    // Web Framework
    implementation("org.springframework.boot:spring-boot-starter-webmvc")
    implementation("org.springframework.boot:spring-boot-starter-actuator")

    // Rate limiting
    val bucket4JVersion = "8.16.1"
    implementation("com.bucket4j:bucket4j_jdk17-core:$bucket4JVersion")
    implementation("com.bucket4j:bucket4j_jdk17-caffeine:$bucket4JVersion")

    // Caching
    implementation("org.springframework.boot:spring-boot-starter-cache")
    implementation("com.github.ben-manes.caffeine:caffeine")

    // JPA/SQL
    implementation("org.springframework.boot:spring-boot-starter-data-jpa")
    runtimeOnly("org.postgresql:postgresql")
    // Flyway
    val flywayVersion = "12.0.1"
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
    implementation("org.bouncycastle:bcprov-jdk18on:1.83")

    // Serialization
    implementation("org.springframework.boot:spring-boot-starter-jackson")
    implementation("tools.jackson.module:jackson-module-kotlin")

    // E-Mail
    implementation("org.springframework.boot:spring-boot-starter-mail")
    implementation("io.pebbletemplates:pebble-spring-boot-starter:4.1.1")

    // Validation
    implementation("org.springframework.boot:spring-boot-starter-validation")

    // OpenAPI
    val springdocVersion = "3.0.1"
    implementation("org.springdoc:springdoc-openapi-starter-webmvc-api:$springdocVersion")
    implementation("org.springdoc:springdoc-openapi-starter-webmvc-ui:$springdocVersion")
    implementation("org.springdoc:springdoc-openapi-starter-webmvc-scalar:$springdocVersion")

    // Annotations
    annotationProcessor("org.springframework.boot:spring-boot-configuration-processor")

    // Kotlin specifics
    implementation("org.jetbrains.kotlin:kotlin-reflect")

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
    testImplementation("org.mockito:mockito-core:5.21.0")
    testImplementation("org.mockito:mockito-junit-jupiter:5.21.0")
    testImplementation("org.mockito.kotlin:mockito-kotlin:6.2.3")

    // AssertJ
    testImplementation("org.assertj:assertj-core:3.27.7")

    // Kotlin specifics
    testImplementation("org.awaitility:awaitility-kotlin:4.3.0")
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
}

tasks.withType<JavaCompile> {
    options.encoding = "UTF-8"
}

tasks.withType<Test> {
    systemProperty("file.encoding", "UTF-8")
}

// tasks.withType<ProcessResources> {
//    filesMatching("application.yaml") {
//        expand(project.properties)
//    }
// }

tasks.processResources {
    // work around IDEA-296490
    // use above when fixed
    duplicatesStrategy = DuplicatesStrategy.INCLUDE
    with(
        copySpec {
            from("src/main/resources/application.yaml") {
                expand(project.properties)
            }
        },
    )
}
