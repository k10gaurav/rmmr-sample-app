# Use a base image with Java and Tomcat pre-installed
FROM tomcat:9-jdk11-temurin-focal

# create a user group and a user
#RUN  addgroup -g 10001 wso2; \
#     adduser -u 10001 -D -g '' -h /usr/local/tomcat/ -G wso2 wso2 ;

RUN groupadd -g 15000 mygroup && \
    useradd -r -u 15000 -g mygroup myuser
     

# Copy the entire folder into the container
COPY rmmr-sample-app.war /usr/local/tomcat/webapps/

# Change ownership of the directory to the non-root user
RUN chown -R ${USER}:${USER_GROUP} /usr/local/tomcat/webapps
RUN chmod -R 777 /usr/local/tomcat

# Expose the default Tomcat port
EXPOSE 8080

# set the user and work directory
USER 15000

# Start Tomcat when the container starts
CMD ["catalina.sh", "run"]
