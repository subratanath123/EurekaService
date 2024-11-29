FROM openjdk:17-jdk-slim

#CMD apt-get update -y

# the JAR file path
ARG JAR_FILE=build/libs/*0.0.1-SNAPSHOT.jar

# Copy the JAR file from the build context into the Docker image
COPY ${JAR_FILE} application.jar

EXPOSE 8761

# Set the default command to run the Java application
ENTRYPOINT ["java", "-Xmx2048M", "-jar", "/application.jar"]