# Copyright (C) 2018 Expedia Inc.
# Licensed under the Apache License, Version 2.0 (the "License");

FROM amazonlinux:latest

# Versions
ARG HADOOP_VERSION=2.7.2
ARG HIVE_VERSION=2.3.0
ENV HADOOP_VERSION=${HADOOP_VERSION}
ENV HIVE_VERSION=${HIVE_VERSION}

ENV JAVA_VERSION 1.8.0
ENV SHUNTING_YARD_VERSION 0.0.3
ENV CIRCUS_TRAIN_VERSION 12.1.0
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

# Hadoop
# RUN curl -s "https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" | tar -xz -C /usr/local && \
#     cd /usr/local && \
#     ln -s ./hadoop-${HADOOP_VERSION} hadoop
ENV HADOOP_HOME /usr/lib/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin

# Get s3 dependencies for Hadoop
# RUN cd $HADOOP_HOME/share/hadoop/common/lib/ && \
#     curl -s -LO "http://central.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_VERSION}/hadoop-aws-${HADOOP_VERSION}.jar" && \
#     cp $HADOOP_HOME/share/hadoop/tools/lib/aws-java-sdk*.jar $HADOOP_HOME/share/hadoop/common/lib && \
#     cp -f $HADOOP_HOME/share/hadoop/tools/lib/jackson* $HADOOP_HOME/share/hadoop/common/lib && \
#     cp -f $HADOOP_HOME/share/hadoop/tools/lib/joda* $HADOOP_HOME/share/hadoop/common/lib

# Hive
# RUN curl -s "https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz" | tar -xz -C /usr/local && \
#     cd /usr/local && \
#     ln -s apache-hive-${HIVE_VERSION}-bin hive
ENV HIVE_HOME /usr/lib/hive
ENV PATH $PATH:$HIVE_HOME/bin

# RUN hdfs dfs -mkdir -p /tmp && \
#     hdfs dfs -mkdir -p /user/hive/warehouse && \
#     hdfs dfs -chmod g+w /tmp && \
#     hdfs dfs -chmod g+w /user/hive/warehouse
#
# RUN $HIVE_HOME/bin/schematool -dbType derby -initSchema

ENV HIVE_LIB /usr/lib/hive/lib/
ENV HCAT_LIB /usr/local/hive/hcatalog/share/hcatalog/

# RUN mv $HIVE_LIB/hive-exec-*.jar $HIVE_LIB/hive-exec.jar && \
#     mv $HIVE_LIB/hive-metastore-*.jar $HIVE_LIB/hive-metastore.jar

RUN wget http://search.maven.org/remotecontent?filepath=com/hotels/shunting-yard-binary/"${SHUNTING_YARD_VERSION}"/shunting-yard-binary-"${SHUNTING_YARD_VERSION}"-bin.tgz -O /tmp/shunting-yard-binary-"${SHUNTING_YARD_VERSION}"-bin.tgz
RUN wget http://search.maven.org/remotecontent?filepath=com/hotels/circus-train/"${CIRCUS_TRAIN_VERSION}"/circus-train-"${CIRCUS_TRAIN_VERSION}"-bin.tgz -O /tmp/circus-train-"${CIRCUS_TRAIN_VERSION}"-bin.tgz

RUN mkdir -p /opt/shunting-yard
RUN mkdir -p /opt/circus-train
RUN tar -vzxf /tmp/shunting-yard-binary-"${SHUNTING_YARD_VERSION}"-bin.tgz -C /opt/shunting-yard/ --strip-components=1
RUN tar -vzxf /tmp/circus-train-"${CIRCUS_TRAIN_VERSION}"-bin.tgz -C /opt/circus-train/ --strip-components=1

COPY files/shunting-yard-variables.conf "${SHUNTING_YARD_HOME}"/conf/
COPY scripts/startup.sh "${SHUNTING_YARD_HOME}"

ENTRYPOINT ["/bin/sh", "-c", "exec ${SHUNTING_YARD_HOME}/startup.sh"]

EXPOSE 9083
