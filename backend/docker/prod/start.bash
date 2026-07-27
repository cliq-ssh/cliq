#!/usr/bin/env bash
set -euo pipefail

# Shared JVM runner for production containers.
# Customize via env vars without duplicating scripts.

JAR_PATH="${JAR_PATH:-application.jar}"

ENABLE_ZGC="${ENABLE_ZGC:-1}"
ENABLE_STRING_DEDUP="${ENABLE_STRING_DEDUP:-1}"
ENABLE_COMPACT_OBJECT_HEADERS="${ENABLE_COMPACT_OBJECT_HEADERS:-1}"
ENABLE_EXIT_ON_OOM="${ENABLE_EXIT_ON_OOM:-1}"

JAVA_SECURITY_EGD="${JAVA_SECURITY_EGD:-file:/dev/./urandom}"
EXTRA_JAVA_OPTS="${EXTRA_JAVA_OPTS:-}"

# Memory settings
INITIAL_RAM_PERCENTAGE="${INITIAL_RAM_PERCENTAGE:-25}"
MIN_RAM_PERCENTAGE="${MIN_RAM_PERCENTAGE:-25}"
MAX_RAM_PERCENTAGE="${MAX_RAM_PERCENTAGE:-75}"

# Optional fixed heap sizes (override percentage settings)
JAVA_XMS="${JAVA_XMS:-}"
JAVA_XMX="${JAVA_XMX:-}"

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

if [[ "${ENABLE_EXIT_ON_OOM}" == "1" ]]; then
  java_opts+=("-XX:+ExitOnOutOfMemoryError")
fi

# Heap sizing
if [[ -n "${JAVA_XMS}" ]]; then
  java_opts+=("-Xms${JAVA_XMS}")
else
  java_opts+=("-XX:InitialRAMPercentage=${INITIAL_RAM_PERCENTAGE}")
fi

if [[ -n "${JAVA_XMX}" ]]; then
  java_opts+=("-Xmx${JAVA_XMX}")
else
  java_opts+=(
    "-XX:MinRAMPercentage=${MIN_RAM_PERCENTAGE}"
    "-XX:MaxRAMPercentage=${MAX_RAM_PERCENTAGE}"
  )
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
