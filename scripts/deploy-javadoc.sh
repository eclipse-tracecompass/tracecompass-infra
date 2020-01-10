#!/usr/bin/env /bin/bash
###############################################################################
# Copyright (c) 2019 École Polytechnique de Montréal
#
# This program and the accompanying materials
# are made available under the terms of the Eclipse Public License 2.0
# which accompanies this distribution, and is available at
# https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
###############################################################################

set -u # run with unset flag error so that missing parameters cause build failure
set -e # error out on any failed commands
set -x # echo all commands used for debugging purposes

SSHUSER="genie.tracecompass@projects-storage.eclipse.org"
SSH="ssh ${SSHUSER}"
SCP="scp"

javadocPath=$1
JAVADOC_REPO="apidocs"

ECHO=echo
if [ "$DRY_RUN" == "false" ]; then
   ECHO=""
else
    echo Dry run of build:
fi

$ECHO ${SSH} "mkdir -p ${JAVADOC_DESTINATION} && \
              rm -rf ${JAVADOC_DESTINATION}/${JAVADOC_REPO}"

$ECHO $SCP -rv ${javadocPath} "${SSHUSER}:${JAVADOC_DESTINATION}"
