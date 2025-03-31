FROM openjdk:17-jdk
WORKDIR /src
COPY build/libs/spring-petclinic-3.4.0.jar /src/spring-petclinic.jar
EXPOSE 8080
CMD ["java","-jar","/src/spring-petclinic.jar"]