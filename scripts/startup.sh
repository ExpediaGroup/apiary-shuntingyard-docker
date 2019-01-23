#!/bin/bash
# Copyright (C) 2018 Expedia Inc.
# Licensed under the Apache License, Version 2.0 (the "License");

SHUNTING_YARD_HOME=/opt/shunting-yard

[[ ! -z $SHUNTINGYARD_CONFIG_YAML ]] && echo "$SHUNTINGYARD_CONFIG_YAML"|base64 -d > ${SHUNTING_YARD_HOME}/conf/shunting-yard-config.yml

[[ -z $HEAPSIZE ]] && export HEAPSIZE=1024

core-site-template() {
cat << EOF
<configuration>
  <property>
    <name>fs.s3a.path.style.access</name>
    <value>true</value>
  </property>

  <property>
    <name>fs.s3.impl</name>
    <value>org.apache.hadoop.fs.s3a.S3AFileSystem</value>
  </property>

  <property>
    <name>fs.s3n.impl</name>
    <value>org.apache.hadoop.fs.s3a.S3AFileSystem</value>
  </property>

  <property>
    <name>fs.s3a.impl</name>
    <value>org.apache.hadoop.fs.s3a.S3AFileSystem</value>
  </property>

  <property>
    <name>fs.s3a.aws.credentials.provider</name>
    <value>com.amazonaws.auth.EC2ContainerCredentialsProviderWrapper</value>
  </property>
</configuration>
EOF
}

core-site-template > $HADOOP_HOME/etc/hadoop/core-site.xml

source "${SHUNTING_YARD_HOME}"/conf/shunting-yard-variables.conf

exec ${SHUNTING_YARD_HOME}/bin/replicator.sh $RUN_ARGS
