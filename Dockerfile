# Copyright (C) 2018 Expedia Inc.
# Licensed under the Apache License, Version 2.0 (the "License");

FROM amazonlinux:latest

# Versions
ARG HADOOP_VERSION=2.7.2
ARG HIVE_VERSION=2.3.0
ENV HADOOP_VERSION=${HADOOP_VERSION}
ENV HIVE_VERSION=${HIVE_VERSION}

ENV JAVA_VERSION 1.8.0
ENV SHUNTING_YARD_VERSION 0.0.5
ENV CIRCUS_TRAIN_VERSION 13.2.1
ENV SHUNTING_YARD_HOME /opt/shunting-yard
ENV CIRCUS_TRAIN_HOME /opt/circus-train

COPY files/RPM-GPG-KEY-emr /etc/pki/rpm-gpg/RPM-GPG-KEY-emr
COPY files/emr-apps.repo /etc/yum.repos.d/emr-apps.repo
COPY files/emr-platform.repo /etc/yum.repos.d/emr-platform.repo

RUN yum -y update && \
  yum install -y java-${JAVA_VERSION}-openjdk \
    procps \
    awscli \
    util-linux \
    tar \
    which \
    jq \
    wget \
    hadoop \
    hive \
  && yum clean all \
  && rm -rf /var/cache/yum

ENV JAVA_HOME /usr/lib/jvm/jre-1.8.0-openjdk/
ENV PATH $PATH:$JAVA_HOME/bin

ENV HADOOP_HOME /usr/lib/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin

ENV HIVE_HOME /usr/lib/hive
ENV PATH $PATH:$HIVE_HOME/bin

ENV HIVE_LIB /usr/lib/hive/lib/
ENV HCAT_LIB /usr/local/hive/hcatalog/share/hcatalog/

RUN wget https://oss.sonatype.org/content/repositories/releases/com/hotels/shunting-yard-binary/0.0.5/shunting-yard-binary-0.0.5-bin.tgz -O /tmp/shunting-yard-binary-"${SHUNTING_YARD_VERSION}"-bin.tgz
RUN wget https://oss.sonatype.org/content/repositories/snapshots/com/hotels/circus-train/13.2.1-SNAPSHOT/circus-train-13.2.1-20190116.130320-4-bin.tgz -O /tmp/circus-train-"${CIRCUS_TRAIN_VERSION}"-bin.tgz

RUN mkdir -p /opt/shunting-yard
RUN mkdir -p /opt/circus-train
RUN tar -vzxf /tmp/shunting-yard-binary-"${SHUNTING_YARD_VERSION}"-bin.tgz -C /opt/shunting-yard/ --strip-components=1
RUN tar -vzxf /tmp/circus-train-"${CIRCUS_TRAIN_VERSION}"-bin.tgz -C /opt/circus-train/ --strip-components=1

COPY files/shunting-yard-variables.conf "${SHUNTING_YARD_HOME}"/conf/
COPY scripts/startup.sh "${SHUNTING_YARD_HOME}"

ENTRYPOINT ["/bin/bash", "-c", "exec ${SHUNTING_YARD_HOME}/startup.sh"]

EXPOSE 9083
