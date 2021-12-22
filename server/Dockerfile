# openjdk 1.8
FROM openjdk:8-jre-slim

ARG JMETER_VERSION="5.4.2"

ENV JMETER_HOME /opt/apache-jmeter-$JMETER_VERSION
ENV JMETER_DOWNLOAD_URL  https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-$JMETER_VERSION.tgz
ENV SSL_DISABLED true

RUN apt-get -qq update \
    && apt-get -yqq install --no-install-recommends curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* 

RUN mkdir -p /tmp/dependencies  \
    && curl -L --silent $JMETER_DOWNLOAD_URL >  /tmp/dependencies/apache-jmeter-$JMETER_VERSION.tgz  \
    && mkdir -p /opt  \
    && tar -xzf /tmp/dependencies/apache-jmeter-$JMETER_VERSION.tgz -C /opt  \
    && rm -rf /tmp/dependencies

# TODO: plugins (later)
# && unzip -oq "/tmp/dependencies/JMeterPlugins-*.zip" -d $JMETER_HOME

# Set global PATH such that "jmeter" command is found
ENV PATH $PATH:$JMETER_HOME/bin
WORKDIR    $JMETER_HOME

EXPOSE 1099 60001

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
