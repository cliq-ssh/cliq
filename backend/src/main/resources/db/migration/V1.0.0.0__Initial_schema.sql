-- ############################################################
-- #                                                          #
-- #                   User & Session                         #
-- #                                                          #
-- ############################################################

CREATE TABLE users
(
    "id"                         BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    "oidc_sub"                   TEXT UNIQUE,
    "email"                      TEXT                     NOT NULL UNIQUE,
    "name"                       TEXT                     NOT NULL,
    "locale"                     TEXT                     NOT NULL,
    "password"                   TEXT                     NOT NULL,
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

CREATE TABLE sessions
(
    "id"               BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    "oidc_session_id"  TEXT UNIQUE,
    "user_id"          BIGINT REFERENCES "users" (id) ON DELETE CASCADE NOT NULL,
    "api_key"          TEXT                                             NOT NULL UNIQUE,
    "name"             TEXT,
    "user_agent"       TEXT,
    "last_accessed_at" timestamp with time zone,
    "created_at"       timestamp with time zone                         NOT NULL,
    "updated_at"       timestamp with time zone                         NOT NULL
);

CREATE INDEX idx_sessions_user_id ON sessions (user_id);
CREATE INDEX idx_sessions_api_key ON sessions (api_key);

-- ############################################################
-- #                                                          #
-- #                   Configurations                         #
-- #                                                          #
-- ############################################################

CREATE TABLE user_configurations
(
    "id"               BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    "user_id"          BIGINT REFERENCES "users" (id) ON DELETE CASCADE UNIQUE NOT NULL,
    "encrypted_config" TEXT                                                    NOT NULL,
    "created_at"       timestamp with time zone                                NOT NULL,
    "updated_at"       timestamp with time zone                                NOT NULL
);
