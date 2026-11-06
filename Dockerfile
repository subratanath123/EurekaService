# Runtime-only image: Gradle never runs inside Docker.
# Build the jar first (CI or locally):  ./gradlew bootJar -x test
# then:                                 docker build -t eureka-service .
#
# The boot jar is split into Spring Boot layers so the dependency layer stays
# cached across deploys and only the small application layer is rebuilt.

FROM eclipse-temurin:17-jre-alpine AS layers
WORKDIR /layers
COPY build/libs/EurekaService.jar app.jar
RUN java -Djarmode=layertools -jar app.jar extract

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Install curl for health checks
RUN apk add --no-cache curl

# Least-frequently-changing layers first
COPY --from=layers /layers/dependencies/ ./
COPY --from=layers /layers/spring-boot-loader/ ./
COPY --from=layers /layers/snapshot-dependencies/ ./
COPY --from=layers /layers/application/ ./

# Create a non-root user for security (Alpine uses addgroup/adduser)
#RUN addgroup -g 1001 -S appgroup && \
#    adduser -u 1001 -S -G appgroup appuser && \
#    chown -R appuser:appgroup /app
#USER appuser

# Expose the port
EXPOSE 8761

# Set default environment variables
ENV JAVA_OPTS="-Xmx256m -Xms128m"

# Run the application. `exec` makes java PID 1 so `docker stop` shuts down gracefully.
# Spring Boot 3.1 launcher package (3.2+ moved it to org.springframework.boot.loader.launch).
ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS org.springframework.boot.loader.JarLauncher"]
