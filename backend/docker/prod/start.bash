#!/usr/bin/env bash

# Use ZGC
# Use string deduplication and compact object headers
exec java \
    -XX:+UseZGC \
    -XX:+UseStringDeduplication \
    -XX:+UseCompactObjectHeaders \
    -Djava.security.egd=file:/dev/./urandom \
    -jar application.jar
