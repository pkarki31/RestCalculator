FROM openjdk:11
ADD ./target/calculator*.jar /usr/app/calculator-0.0.1-SNAPSHOT.jar
WORKDIR /usr/app
EXPOSE 8085
ENTRYPOINT ["java","-jar","calculator-0.0.1-SNAPSHOT.jar"]