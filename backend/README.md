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

## Linting and formatting

Lints and formats the code also automatically apply all suggested fixes:

```bash
./gradlew detekt --auto-correct
```
