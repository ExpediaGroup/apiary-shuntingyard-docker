#!/bin/bash
# Copyright (C) 2019 Expedia Inc.
# Licensed under the Apache License, Version 2.0 (the "License");

SHUNTING_YARD_HOME=/opt/shunting-yard

[[ ! -z $SHUNTINGYARD_CONFIG_YAML ]] && echo "$SHUNTINGYARD_CONFIG_YAML"|base64 -d > ${SHUNTING_YARD_HOME}/conf/shunting-yard-config.yml
[[ ! -z $CT_COMMON_CONFIG_YAML ]] && echo "$CT_COMMON_CONFIG_YAML"|base64 -d > ${SHUNTING_YARD_HOME}/conf/ct-common-config.yml
[[ ! -z $CT_LOG4J_XML ]] && echo "$CT_LOG4J_XML"|base64 -d > ${SHUNTING_YARD_HOME}/conf/log4j-ct.xml

[[ -z $HEAPSIZE ]] && export HEAPSIZE=1024

source "${SHUNTING_YARD_HOME}"/conf/shunting-yard-variables.conf

exec ${SHUNTING_YARD_HOME}/bin/replicator.sh $JAVA_OPTS $RUN_ARGS
