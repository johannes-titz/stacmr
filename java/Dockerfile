FROM maven:3.9.2-eclipse-temurin-17

WORKDIR /build

# Install git (maven image already has JDK + Maven)
RUN apt-get update && apt-get install -y git

# Clone the source
RUN git clone https://github.com/michaelkalish/STA.git

# Build the jar
WORKDIR /build/STA/Java\ Source/java\ source
RUN mvn package -DskipTests

# Copy jar-with-dependencies to a predictable location
RUN mkdir /out && \
    cp target/*-jar-with-dependencies.jar /out/
