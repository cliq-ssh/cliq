plugins {
    // Kotlin
    kotlin("jvm") version "2.2.10"
    kotlin("plugin.spring") version "2.2.10"
    kotlin("plugin.jpa") version "2.2.10"
    kotlin("plugin.allopen") version "2.2.10"

    // Spring / Spring Boot
    id("org.springframework.boot") version "3.5.5"
    id("io.spring.dependency-management") version "1.1.7"

    // Database Migrations
    id("org.flywaydb.flyway") version "11.11.2"

    // Linter and Formatter
    id("org.jlleitschuh.gradle.ktlint") version "13.1.0"
}

group = "app.cliq"
version = "0.1.0"
description = "Open source SSH & SFTP client with focus on security and portability"

val targetJvmVersion = 24

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
    version.set("1.7.1")
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

repositories {
    mavenCentral()
}

buildscript {
    dependencies {
        classpath("org.flywaydb:flyway-database-postgresql:11.11.2")
    }
}

val greenmailVersion = "2.1.5"

dependencies {
    // Web Framework
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-actuator")

    // JPA/SQL
    implementation("org.springframework.boot:spring-boot-starter-data-jpa")
    implementation("org.flywaydb:flyway-core:11.11.2")
    implementation("org.flywaydb:flyway-database-postgresql:11.11.2")
    runtimeOnly("org.postgresql:postgresql")

    // Security
    implementation("org.springframework.boot:spring-boot-starter-security")
    implementation("org.springframework.security:spring-security-crypto")
    implementation("org.bouncycastle:bcprov-jdk18on:1.81")

    // E-Mail
    implementation("org.springframework.boot:spring-boot-starter-mail")
    implementation("org.springframework.boot:spring-boot-starter-thymeleaf")

    // Validation
    implementation("org.springframework.boot:spring-boot-starter-validation")

    // OpenAPI
    implementation("org.springdoc:springdoc-openapi-starter-webmvc-ui:2.8.11")

    // Annotations
    annotationProcessor("org.springframework.boot:spring-boot-configuration-processor")

    // Kotlin specifics
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.10.2")
    implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
    implementation("org.jetbrains.kotlin:kotlin-reflect")

    // Testing //

    // Spring
    testImplementation("org.springframework.boot:spring-boot-starter-test")

    // Junit 5
    testImplementation("org.jetbrains.kotlin:kotlin-test-junit5")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")

    // Greenmail
    implementation("com.icegreen:greenmail-spring:$greenmailVersion")
    testImplementation("com.icegreen:greenmail:$greenmailVersion")
    testImplementation("com.icegreen:greenmail-junit5:$greenmailVersion")

    // Mail commons
    testImplementation("org.apache.commons:commons-email2-jakarta:2.0.0-M1")

    // Kotlin specifics
    testImplementation("org.mockito.kotlin:mockito-kotlin:6.0.0")
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
