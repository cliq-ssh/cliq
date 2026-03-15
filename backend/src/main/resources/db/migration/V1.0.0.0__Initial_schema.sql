-- ############################################################
-- #                                                          #
-- #                   User & Session                         #
-- #                                                          #
-- ############################################################

CREATE TABLE users
(
    "id"                         BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    "oidc_sub"                   TEXT UNIQUE,
    "srp_salt"                   TEXT,
    "srp_verifier"               TEXT,
    "data_encryption_key"        TEXT,
    "email"                      TEXT                     NOT NULL UNIQUE,
    "name"                       TEXT                     NOT NULL,
    "locale"                     TEXT                     NOT NULL,
    "reset_token"                TEXT,
    "reset_sent_at"              timestamp with time zone,
    "email_verification_token"   TEXT,
    "email_verification_sent_at" timestamp with time zone,
    "email_verified_at"          timestamp with time zone,
    "created_at"                 timestamp with time zone NOT NULL,
    "updated_at"                 timestamp with time zone NOT NULL,
    UNIQUE ("email", "email_verification_token"),
    UNIQUE ("email", "reset_token")
);

CREATE TABLE auth_exchanges
(
    "id"            BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    "user_id"       BIGINT REFERENCES users (id) ON DELETE CASCADE NOT NULL,
    "exchange_code" TEXT                                           NOT NULL UNIQUE,
    "ip_address"    inet                                           NOT NULL,
    "created_at"    timestamp with time zone                       NOT NULL,
    "expires_at"    timestamp with time zone                       NOT NULL
);

CREATE INDEX idx_auth_exchanges_exchange_code ON auth_exchanges (exchange_code);

CREATE TABLE oidc_callback_token
(
    "id"               BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    "auth_exchange_id" BIGINT REFERENCES auth_exchanges (id) ON DELETE CASCADE NOT NULL UNIQUE,
    "oidc_session_id"  TEXT UNIQUE,
    "token"            TEXT                                                    NOT NULL UNIQUE,
    "created_at"       timestamp with time zone                                NOT NULL
);

CREATE INDEX idx_oidc_callback_token_token ON oidc_callback_token (token);

CREATE TABLE sessions
(
    "id"              BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    "oidc_session_id" TEXT UNIQUE,
    "user_id"         BIGINT REFERENCES "users" (id) ON DELETE CASCADE NOT NULL,
    "refresh_token"   TEXT                                             NOT NULL UNIQUE,
    "name"            TEXT,
    "last_used_at"    timestamp with time zone,
    "expires_at"      timestamp with time zone                         NOT NULL,
    "created_at"      timestamp with time zone                         NOT NULL
);

CREATE INDEX idx_sessions_user_id ON sessions (user_id);
CREATE INDEX idx_sessions_oidc_session_id ON sessions (oidc_session_id);
CREATE INDEX idx_sessions_refresh_token ON sessions (refresh_token);

-- ############################################################
-- #                                                          #
-- #                   Configurations                         #
-- #                                                          #
-- ############################################################

CREATE TABLE vaults
(
    "id"               BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    "user_id"          BIGINT REFERENCES "users" (id) ON DELETE CASCADE UNIQUE NOT NULL,
    "encrypted_config" TEXT                                                    NOT NULL,
    "version"          TEXT                                                    NOT NULL,
    "created_at"       timestamp with time zone                                NOT NULL,
    "updated_at"       timestamp with time zone                                NOT NULL
);
