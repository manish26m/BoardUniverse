# ─────────────────────────────────────────────────
# BoardUniverse - Dockerfile
# Multi-stage build for optimized image size
# ─────────────────────────────────────────────────

# Stage 1: Build the application using Maven + Java 21
FROM maven:3.9.9-eclipse-temurin-21 AS build
WORKDIR /app

# Copy pom.xml first for dependency caching
COPY pom.xml .
RUN mvn -B -q -DskipTests dependency:go-offline

# Copy source code and build the JAR
COPY src ./src
RUN mvn clean package -DskipTests


# ─────────────────────────────────────────────────
# Stage 2: Lightweight runtime image
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Copy built JAR from build stage
COPY --from=build /app/target/*.jar app.jar

# Expose application port
EXPOSE 8080

# Start application
ENTRYPOINT ["java", "-jar", "app.jar"]