<!-- TOC -->
* [Authentication](#authentication)
* [Goal](#goal)
  * [Endpoint usage](#endpoint-usage)
* [Auth Types](#auth-types)
  * [Local auth](#local-auth)
  * [OIDC](#oidc)
    * [Roles](#roles)
    * [Goal](#goal-1)
    * [Overview](#overview)
* [Description](#description)
  * [Requirements](#requirements)
  * [Backwards compatibility](#backwards-compatibility)
  * [Nice to haves](#nice-to-haves)
  * [Other relevant information](#other-relevant-information)
<!-- TOC -->

# Authentication

This document describes the new authentication system for cliq.

# Goal

The goal is to add OIDC support and to abstract away the authentication details.  
At the endpoint level, the user should only be available, and it should be irrelevant how the user got authenticated.

## Endpoint usage

The following code describes how the new authentication system would be used inside a controller.

```kotlin
@Authenticated
@GetMapping
fun get(
    @AuthenticationPrincipal user: User,
): ResponseEntity<String> {
    return ResponseEntity.ok("Hello, ${principal.name}!")
}
```

# Auth Types

## Local auth

Local auth works by providing a REST endpoint where the user can send their username and password.
This endpoint will then create a "session" Entity that contains an API-Token. In this case the session is not an HTTP
session, but a persistent entity in the database containing metadata about the user and API Key.

This API-Token can then be used to authenticate the user for future requests.

The end goal is that the frontend app will call this endpoint, store the API-Token and use it for future requests.

## OIDC

### Roles

- **OIDC Provider (IdP)**
    - Examples: Keycloak, Authentik, Google, etc.
- **Backend (API)**
    - OIDC Client
    - Handles client secrets
    - Handles SLO (Single-Logout)
    - Exchanges authorization code for access token
    - Issues session tokens
- **Frontend (App)**
    - Never sees OIDC Client secrets
    - Never talks directly to the IdP
    - Uses tokens issued by the backend

### Goal

The end goal is that a user can authenticate via OIDC and get a session token.
If the user gets logged out by the IdP, the session token should be invalidated using SLO (Single-Logout).

**Flow:**

User -> App -> Backend -> IdP -> App

### Overview

If OIDC support is enabled, the user can authenticate using the configured OIDC provider.

If OIDC support is enabled, the user can authenticate via OIDC.
This will be done via the standard OIDC flow.

The login gets handled by the frontend.
The backend will only accept logged-in users.

The backend will initiate the OIDC flow and do everything necessary to authenticate the user.
After that the IdP should redirect back to the app/frontend.

We will have one endpoint that gives the app the information which IdP URL to use. (`/api/oauth/authorize`)

# Description

## Requirements

- stateless
- support for local auth and OIDC
- local auth and OIDC must work together
- OIDC must be optional
- backend does not initialize authentication
    - for local auth, we only provide a REST POST endpoint
- good integration in spring 7 and spring boot 4
- support for single-logout with OIDC (Backchannel Logout)

## Backwards compatibility

- current systems can be reworked
- no need for backwards compatibility

## Nice to haves

- support for multiple authentication providers
- define public and private endpoints via annotations

## Other relevant information

- don't be framework-agnostic
    - it is possible to only support Spring/Spring Boot
