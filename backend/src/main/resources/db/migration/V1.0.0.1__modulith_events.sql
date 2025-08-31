-- SQL script to create the EVENT_PUBLICATION table used by spring modulith
-- Copied from: https://docs.spring.io/spring-modulith/docs/0.1.0-M1/reference/html/#appendix.schemas.postgresql

CREATE TABLE IF NOT EXISTS EVENT_PUBLICATION
(
    ID               UUID                        NOT NULL,
    LISTENER_ID      VARCHAR(512)                NOT NULL,
    EVENT_TYPE       VARCHAR(512)                NOT NULL,
    SERIALIZED_EVENT VARCHAR(4000)               NOT NULL,
    PUBLICATION_DATE TIMESTAMP(6) WITH TIME ZONE NOT NULL,
    COMPLETION_DATE  TIMESTAMP(6) WITH TIME ZONE,
    PRIMARY KEY (ID)
);
