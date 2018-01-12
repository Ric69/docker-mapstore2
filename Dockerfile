FROM tomcat:7.0.75
MAINTAINER geosolutions<info@geo-solutions.it>

RUN  export DEBIAN_FRONTEND=noninteractive
ENV  DEBIAN_FRONTEND noninteractive
RUN  dpkg-divert --local --rename --add /sbin/initctl

# Set JAVA_HOME to /usr/lib/jvm/default-java and link it to OpenJDK installation
RUN ln -s /usr/lib/jvm/java-1.7.0-openjdk-amd64/ /usr/lib/jvm/default-java
ENV JAVA_HOME /usr/lib/jvm/default-java

# Install utilities
RUN  apt-get -y update \
     && apt-get -y install vim \
     && rm -rf /var/lib/apt/lists/*

# Tomcat specific stuff
ENV CATALINA_BASE "$CATALINA_HOME"
ENV JAVA_OPTS="${JAVA_OPTS}  -Xms512m -Xmx512m -XX:MaxPermSize=128m"

# Optionally remove Tomcat manager, docs, and examples
ARG TOMCAT_EXTRAS=false
RUN if [ "$TOMCAT_EXTRAS" = false ]; then \
      find "${CATALINA_BASE}/webapps/" -type f | xargs -L1 rm -f \
    ;fi

# Customize Tomcat
ARG APP_NAME=mapstore
COPY ./mapstore.war "${CATALINA_BASE}/webapps/${APP_NAME}.war"

# Customize GeoServer datasource properties
ADD geostore-datasource-ovr.properties "${CATALINA_BASE}/conf/"
ARG GEOSTORE_OVR_OPT=""
ENV JAVA_OPTS="${JAVA_OPTS} ${GEOSTORE_OVR_OPT}"

# Add startup wrapper script
ADD wait-for-postgres.sh "${CATALINA_BASE}/bin/"

# Set variable to better handle terminal commands
ENV TERM xterm

EXPOSE 8080
