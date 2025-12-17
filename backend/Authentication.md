<!-- TOC -->
* [Authentication](#authentication)
* [Goal](#goal)
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

# Description

## Requirements

- stateless
- support for local auth and OIDC
- local auth and OIDC must work together
- OIDC must be optional
- backend does not initialize authentication
    - for local auth, we only provide a REST POST endpoint
- good integration in spring 7 and spring boot 4

## Backwards compatibility

- current systems can be reworked
- no need for backwards compatibility

## Nice to haves

- support for multiple authentication providers
- define public and private endpoints via annotations

## Other relevant information

- don't be framework-agnostic
    - it is possible to only support Spring/Spring Boot
