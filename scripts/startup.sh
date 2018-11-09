#!/bin/bash
# Copyright (C) 2018 Expedia Inc.
# Licensed under the Apache License, Version 2.0 (the "License");

SHUNTING_YARD_HOME=/opt/shunting-yard

[[ ! -z $SERVER_YAML ]] && echo $SERVER_YAML|base64 -d > ${SHUNTING_YARD_HOME}/conf/waggle-dance-server.yml

[[ ! -z $FEDERATION_YAML ]] && echo $FEDERATION_YAML|base64 -d > ${SHUNTING_YARD_HOME}/conf/waggle-dance-federation.yml

[[ -z $HEAPSIZE ]] && export HEAPSIZE=1024

if [[ -n $BASTION_SSH_KEY_ARN ]] ; then
  mkdir -p /root/.ssh
  touch /root/.ssh/known_hosts
  aws secretsmanager get-secret-value --secret-id ${BASTION_SSH_KEY_ARN}|jq .SecretString -r|jq .private_key -r| base64 -d > /root/.ssh/bastion_ssh
fi

#!/bin/bash

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
</configuration>
EOF
}

core-site-template > $HADOOP_HOME/etc/hadoop/core-site.xml

mv $HIVE_LIB/hive-exec-*.jar $HIVE_LIB/hive-exec.jar
mv $HIVE_LIB/hive-metastore-*.jar $HIVE_LIB/hive-metastore.jar

circus-train*/bin/circus-train.sh --config=$CIRCUS_TRAIN_CONF

source "${SHUNTING_YARD_HOME}"/service/waggle-dance-core-latest-exec.conf

exec java -jar "${SHUNTING_YARD_HOME}"/service/waggle-dance-core-latest-exec.jar  $JAVA_OPTS $RUN_ARGS
