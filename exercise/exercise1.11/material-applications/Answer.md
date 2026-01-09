    FROM amazoncorretto:8
    EXPOSE 8080
    WORKDIR /usr/src/app
    COPY . .
    RUN ./mvnw package
    CMD [ "java", "-jar", "./target/docker-example-1.1.3.jar" ]

Build

    docker build . -t spring-project

Run

    docker run -p 8080:8080 spring-project