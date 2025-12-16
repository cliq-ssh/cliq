# CLIq Backend

// ...existing content...

## Authentication Roadmap
- Replace bespoke API key sessions with Spring Security primitives so both local email/password and OIDC logins reuse the same infrastructure.
- Introduce a domain `AuthenticatedUser` abstraction that unifies identities regardless of credential source and can capture optional tenant/provider metadata.
- Keep local credentials by exposing a JWT-issuing login endpoint while wiring `oauth2ResourceServer` + `oauth2Login` for Keycloak, GitHub, and future providers.
- Externalize issuer/client settings (and optional tenant routing) via `application.yaml` to simplify adding providers without code changes.
- Update controllers/tests/docs to consume the new principal model and drop dependencies on the legacy `session` package.

