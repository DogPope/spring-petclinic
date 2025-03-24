# This is a sample, it doesn't really correspond with what I'm doing.
# FROM openjdk:8-jdk-alpine
# RUN addgroup -S daniel && adduser daniel -S spring -G spring
# USER spring:spring
# ARG JAR_FILE=build/libs/*.jar
# COPY ${JAR_FILE} spring-petclinic-1.0.jar
# ENTRYPOINT ["java", "-jar", "/spring-petclinic-1.0.jar"]