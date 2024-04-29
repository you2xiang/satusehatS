FROM openjdk:21-jdk-bullseye
VOLUME /tmp
EXPOSE 8000
ADD target/*.jar app.jar
ENV JAVA_OPTS=""

RUN mkdir -p /opt/cprof && \
  wget -q -O- https://storage.googleapis.com/cloud-profiler/java/latest/profiler_java_agent.tar.gz \
  | tar xzv -C /opt/cprof
  

CMD ["java", \
    "-agentpath:/opt/cprof/profiler_java_agent.so=-cprof_service=satusehatfhirservice,-cprof_service_version=1.0.0,-logtostderr,-minloglevel=0", \
     "-jar", "app.jar" ]
    
