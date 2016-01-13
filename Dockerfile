FROM ubuntu:trusty

MAINTAINER Randy Ridgley randy.ridgley@gmail.com

ENV KAFKA_VERSION="0.8.2.1"
ENV SCALA_VERSION="2.10"
ENV JAVA_VERSION=8
ENV JAVA_HOME=/usr/lib/jvm/java-8-oracle"

ENV \
    KAFKA_RELEASE="http://apache.mesi.com.ar/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" \
    BUILD_DEPS="curl software-properties-common docker.io jq" \
    DEBIAN_FRONTEND="noninteractive"

# install java8
RUN echo 'deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main' >> /etc/apt/sources.list && \
    echo 'deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main' >> /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C2518248EEA14886 && \
    apt-get update && \
    echo oracle-java${JAVA_VERSION}-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections && \
    apt-get install -y --force-yes --no-install-recommends oracle-java${JAVA_VERSION}-installer oracle-java${JAVA_VERSION}-set-default && \
    apt-get install -y --allow-unauthenticated --no-install-recommends $BUILD_DEPS && \

    # Install Kafka
    curl -Lo /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz $KAFKA_RELEASE && \
    mkdir -p /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} && \
    tar -xf /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} --strip=1 && \
    rm /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz

VOLUME ["/kafka"]

ENV KAFKA_HOME /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION}
ADD include/start-kafka.sh /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION}/bin/start-kafka.sh
ADD include/broker-list.sh /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION}/bin/broker-list.sh

WORKDIR /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION}
RUN chmod +x ./bin/start-kafka.sh
RUN chmod +x ./bin/broker-list.sh

EXPOSE 9092 9999

CMD /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION}/bin/start-kafka.sh