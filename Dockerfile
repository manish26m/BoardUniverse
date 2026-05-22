# ─────────────────────────────────────────────────
# BoardUniverse - Dockerfile
# Multi-stage build for optimized image size
# ─────────────────────────────────────────────────

# Stage 1: Build the application using Maven
FROM maven:3.9.9-eclipse-temurin-17 AS build
WORKDIR /app

# Copy pom.xml first so Maven dependencies are cached
# This avoids re-downloading deps on every build
COPY pom.xml .
RUN mvn -B -q -DskipTests dependency:go-offline

# Copy source code and build the JAR
COPY src ./src
RUN mvn clean package -DskipTests

# ─────────────────────────────────────────────────
# Stage 2: Lightweight runtime image
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Copy only the built JAR from the build stage
COPY --from=build /app/target/*.jar app.jar

# Expose the port the app runs on
EXPOSE 8080

# Start the application
ENTRYPOINT ["java", "-jar", "app.jar"]
