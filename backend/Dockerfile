# -----------------------------------------------------------------------
# Stage 1: Build - uses a full Maven+JDK image, compiles and packages
# the app into a jar. This entire stage is discarded from the final
# image - only its output (the jar) gets copied forward.
# -----------------------------------------------------------------------
FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app

# Copy pom.xml first and download dependencies separately from copying
# source code - Docker caches this layer, so if only your Java code
# changes (not pom.xml), rebuilds skip re-downloading all dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

COPY src ./src
RUN mvn clean package -DskipTests -B

# -----------------------------------------------------------------------
# Stage 2: Runtime - a minimal JRE-only image, much smaller than
# carrying the full JDK+Maven toolchain into production
# -----------------------------------------------------------------------
FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

# Run as a non-root user - basic container security hygiene
RUN addgroup --system spring && adduser --system --ingroup spring spring
USER spring:spring

COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
