#!/usr/bin/env bash

# Use ZGC and string deduplication
# Use compact object headers
exec java \
    -XX:+UseZGC \
    -XX:+UseStringDeduplication \
    -XX:+UseCompactObjectHeaders \
    -Djava.security.egd=file:/dev/./urandom \
    -jar application.jar
