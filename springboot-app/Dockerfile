FROM eclipse-temurin:21-jdk
WORKDIR /app
COPY helloworld.jar .
RUN useradd --create-home --uid 10001 appuser
USER appuser
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "helloworld.jar"]


