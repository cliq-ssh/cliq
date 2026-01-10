# cliq backend

## Users

| Username | email          | password | type          |
|----------|----------------|----------|---------------|
| test     | test@cliq.test | Cliq123  | OIDC/Keycloak |

## Gradle usefully commands

## Building the project

Builds the runnable jar file in the `build/libs` directory:

```bash
./gradlew bootJar
```

## Analyze dependencies

Useful to find unused dependencies.
This currently does not work reliably with Spring Boot projects. The correct configuration is still missing, so please
take a look and test if a dependency can actually be removed or changed.

```bash
./gradlew buildHealth
```

## Linting and formatting

Lints and formats the code also automatically apply all suggested fixes:

```bash
./gradlew ktlintFormat
```

Lints the code:

```bash
./gradlew ktlintCheck
```
