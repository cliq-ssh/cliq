#!/usr/bin/env bash
set -euo pipefail

# Shared JVM runner for production containers.
# Customize via env vars without duplicating scripts.

JAR_PATH="${JAR_PATH:-application.jar}"

ENABLE_ZGC="${ENABLE_ZGC:-1}"
ENABLE_STRING_DEDUP="${ENABLE_STRING_DEDUP:-1}"
ENABLE_COMPACT_OBJECT_HEADERS="${ENABLE_COMPACT_OBJECT_HEADERS:-1}"

JAVA_SECURITY_EGD="${JAVA_SECURITY_EGD:-file:/dev/./urandom}"
EXTRA_JAVA_OPTS="${EXTRA_JAVA_OPTS:-}"

java_opts=()

if [[ "${ENABLE_ZGC}" == "1" ]]; then
  java_opts+=("-XX:+UseZGC")
fi

if [[ "${ENABLE_STRING_DEDUP}" == "1" ]]; then
  java_opts+=("-XX:+UseStringDeduplication")
fi

if [[ "${ENABLE_COMPACT_OBJECT_HEADERS}" == "1" ]]; then
  java_opts+=("-XX:+UseCompactObjectHeaders")
fi

java_opts+=("-Djava.security.egd=${JAVA_SECURITY_EGD}")

# Allow passing additional JVM args via env (space-separated).
if [[ -n "${EXTRA_JAVA_OPTS}" ]]; then
  # shellcheck disable=SC2206
  extra_opts=( ${EXTRA_JAVA_OPTS} )
  java_opts+=("${extra_opts[@]}")
fi

echo "Starting application with JVM options: ${java_opts[*]}"

exec java "${java_opts[@]}" -jar "${JAR_PATH}"
