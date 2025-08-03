ARG JDK_VERSION=24
ARG JRE_VERSION=24
ARG TEMURIN_ALPINE_VERSION=3.21
ARG ALPINE_VERSION=3.22

# Stage 1: Build the application
FROM eclipse-temurin:${JDK_VERSION}-jdk-alpine-${TEMURIN_ALPINE_VERSION} AS builder

WORKDIR /app

# Copy gradle files first for better cache utilization
COPY gradlew .
COPY gradle gradle
COPY build.gradle* .
COPY settings.gradle* .
COPY gradle.properties* ./

# Download dependencies (cached layer)
RUN chmod +x ./gradlew && \
    ./gradlew dependencies --no-daemon

# Copy source code and build
COPY src src
RUN ./gradlew bootJar --no-daemon

# Copy jar file to the working directory and rename it to application.jar
RUN cp build/libs/*.jar application.jar

# Extract the jar file using an efficient layout (see Spring Boot documentation)
RUN java -Djarmode=tools -jar application.jar extract --layers --destination extracted

# Stage 2: Create cliq jre with jlink
FROM eclipse-temurin:${JRE_VERSION}-jdk-alpine-${TEMURIN_ALPINE_VERSION} AS jre-builder

WORKDIR /jre-build
COPY --from=builder /app/application.jar .

# Extract the jar file to analyze its dependencies
RUN jar xf application.jar

# Identify required modules with jdeps
RUN jdeps --ignore-missing-deps -q \
    --recursive \
    --multi-release 24 \
    --print-module-deps \
    --class-path 'BOOT-INF/lib/*' \
    application.jar > deps.info

# Create minimal JRE with only required modules
RUN jlink \
    --add-modules $(cat deps.info) \
    --strip-debug \
    --compress zip-9 \
    --no-header-files \
    --no-man-pages \
    --output /cliq-jre

# Stage 3: Final minimal runtime image
FROM alpine:${ALPINE_VERSION}

# User creation
ARG UID=1000
ARG GUID=1000
ARG USER_NAME=cliq
ENV GROUP_NAME=${USER_NAME}
ENV HOME_DIR=/home/${USER_NAME}
ENV WORK_DIR=${HOME_DIR}/backend

ENV JAVA_HOME=/opt/java
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Add curl, bash and update package repositories
RUN apk update && \
    apk add --no-cache curl bash

# Create a non-root user
RUN addgroup -g ${UID} -S ${GROUP_NAME} && \
    adduser -u ${GUID} -S -D -G ${GROUP_NAME} -h ${HOME_DIR} -s /bin/sh ${USER_NAME}

WORKDIR ${WORK_DIR}

# Copy custom JRE and extracted application layers
COPY --from=jre-builder /cliq-jre $JAVA_HOME
COPY --from=builder --chown=${UID}:${GUID} /app/extracted/dependencies/ ./
COPY --from=builder --chown=${UID}:${GUID} /app/extracted/spring-boot-loader/ ./
COPY --from=builder --chown=${UID}:${GUID} /app/extracted/snapshot-dependencies/ ./
COPY --from=builder --chown=${UID}:${GUID} /app/extracted/application/ ./

# Copy startup script
COPY --chown=${UID}:${GUID} docker/prod/start.bash ${WORK_DIR}/start.bash
RUN chmod +x ${WORK_DIR}/start.bash

USER ${USER_NAME}

EXPOSE 8080

#HEALTHCHECK --interval=30s --timeout=3s \
#  CMD curl -f http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["./start.bash"]
