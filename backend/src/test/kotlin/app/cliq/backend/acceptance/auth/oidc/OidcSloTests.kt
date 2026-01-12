package app.cliq.backend.acceptance.auth.oidc

import app.cliq.backend.acceptance.AcceptanceTest
import app.cliq.backend.acceptance.AcceptanceTester

/*
TODO:
    - test logout with sid
    - test logout without sid
    - test logout from unknow user with sid
    - test logout from unknow user without sid
 */
@AcceptanceTest
class OidcSloTests : AcceptanceTester()
