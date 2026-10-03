FROM maven:3.9.9-eclipse-temurin-21 AS build
WORKDIR /workspace
COPY pom.xml .
COPY src ./src
RUN mvn -q -DskipTests package

FROM eclipse-temurin:21-jre
WORKDIR /app
RUN useradd --system --uid 10001 campus
COPY --from=build /workspace/target/campus-tasks-api-1.0.0.jar app.jar
RUN chown campus:campus app.jar
USER campus
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar"]
