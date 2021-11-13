FROM ubuntu:focal

RUN set -xe; \
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get install -y \
      libcairo2-dev \
      libjpeg-turbo8-dev \
      libpng-dev \
      libtool-bin \
      libossp-uuid-dev \
      freerdp2-dev \
      libpango1.0-dev \
      libssh2-1-dev \
      libavcodec-dev \
      libavformat-dev \
      libavutil-dev \
      libswscale-dev \
      libvncserver-dev \
      libwebsockets-dev \
      libpulse-dev \
      libssl-dev \
      libvorbis-dev \
      libwebp-dev \
      curl \
      build-essential \
      tomcat9 \
      python3-pip \
      mysql-server \
    ; \
    rm -rf /var/lib/mysql; \
    pip3 install "supervisor~=4.2"; \
    rm -rf /var/lib/tomcat9/webapps/ROOT;

ENV GUAC_VER=1.3.0


# Guacamole server installation
RUN set -xe; \
    mkdir -p /tmp; \
    cd /tmp; \
    curl -SLO "http://apache.org/dyn/closer.cgi?action=download&filename=guacamole/${GUAC_VER}/source/guacamole-server-${GUAC_VER}.tar.gz"; \
    tar -xzf guacamole-server-${GUAC_VER}.tar.gz; \
    cd guacamole-server-${GUAC_VER}; \
    ./configure --enable-allow-freerdp-snapshots; \
    make -j$(nproc); \
    make install; \
    cd ..; \
    rm -rf /tmp; \
    mkdir /tmp; \
    ldconfig # the install manual says to do this

ENV GUACAMOLE_HOME=/app/guacamole

# Guacamole client installation
RUN set -xe; \
    mkdir -p /app/data /app/tmp ${GUACAMOLE_HOME} ${GUACAMOLE_HOME}/extensions ${GUACAMOLE_HOME}/lib; \
    curl -SLo /var/lib/tomcat9/webapps/ROOT.war "http://apache.org/dyn/closer.cgi?action=download&filename=guacamole/${GUAC_VER}/binary/guacamole-${GUAC_VER}.war"

# MySQL adapter
RUN set -xe; \
    cd /tmp; \
    curl -SLO "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.27.tar.gz"; \
    tar xf mysql-connector-java-8.0.27.tar.gz; \
    cp mysql-connector-java-8.0.27/mysql-connector-java-8.0.27.jar ${GUACAMOLE_HOME}/lib; \
    curl -SLO "http://apache.org/dyn/closer.cgi?action=download&filename=guacamole/${GUAC_VER}/binary/guacamole-auth-jdbc-${GUAC_VER}.tar.gz"; \
    tar xf guacamole-auth-jdbc-${GUAC_VER}.tar.gz; \
    cp guacamole-auth-jdbc-${GUAC_VER}/mysql/guacamole-auth-jdbc-mysql-${GUAC_VER}.jar ${GUACAMOLE_HOME}/extensions; \
    cp -R guacamole-auth-jdbc-${GUAC_VER}/mysql/schema $GUACAMOLE_HOME/schema; \
    cd /; \
    rm -rf /tmp; \
    mkdir /tmp

COPY app /app

RUN set -xe; \
    ln -s /app/data/guacamole/user-mapping.xml /app/guacamole/user-mapping.xml

CMD ["/usr/local/bin/supervisord", "-c", "/app/supervisord.conf"]
