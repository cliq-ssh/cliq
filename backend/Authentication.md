<!-- TOC -->
* [Authentication](#authentication)
* [Goal](#goal)
  * [Endpoint usage](#endpoint-usage)
* [Auth Types](#auth-types)
  * [Local auth](#local-auth)
  * [OIDC](#oidc)
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

## OIDC

If OIDC support is enabled, the user can authenticate via OIDC.
This will be done via the standard OIDC flow.

The login gets handled by the frontend.
The backend will only accept logged-in users.

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
