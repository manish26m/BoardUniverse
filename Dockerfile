# ─────────────────────────────────────────────────
# BoardUniverse - Dockerfile
# Multi-stage build for optimized image size
# ─────────────────────────────────────────────────

# Stage 1: Build the application using Maven + Java 17
FROM maven:3.9.9-eclipse-temurin-17 AS build
WORKDIR /app

# Copy pom.xml first for dependency caching
COPY pom.xml .
RUN mvn -B -q -DskipTests dependency:go-offline

# Copy source code and build the JAR
COPY src ./src
RUN mvn clean package -DskipTests


# ─────────────────────────────────────────────────
# Stage 2: Lightweight runtime image
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Create a non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy built JAR from build stage and assign ownership to appuser
COPY --from=build --chown=appuser:appgroup /app/target/*.jar app.jar

# Expose application port
EXPOSE 8080

# Run the container as the non-root user
USER appuser

# Start application
ENTRYPOINT ["java", "-jar", "app.jar"]