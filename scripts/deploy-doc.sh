#!/usr/bin/env /bin/bash
###############################################################################
# Copyright (c) 2019 Ericsson.
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

DOC_BASE_PATH=doc
DOC_DIRS=`ls ${DOC_BASE_PATH} | grep org.eclipse.tracecompass | grep doc`
DOC_ZIP_FILE="doc-deployment.zip"

ECHO=echo
if [ "$DRY_RUN" == "false" ]; then
   ECHO=""
else
    echo Dry run of build:
fi

$ECHO ${SSH} "mkdir -p ${DOC_DESTINATION} && \
              rm -f ${DOC_DESTINATION}/${DOC_ZIP_FILE}"

for DOC_NAME in $DOC_DIRS
do
	$ECHO $SSH "rm -rf ${DOC_DESTINATION}/${DOC_NAME}"
done

ZIP_INPUT="org.eclipse.tracecompas*"
ZIP_PATH=${DOC_BASE_PATH}/.temp

$ECHO cd ${ZIP_PATH}; $ECHO zip -r ${DOC_ZIP_FILE} ${ZIP_INPUT}; $ECHO cd -;
$ECHO $SCP ${ZIP_PATH}/${DOC_ZIP_FILE} "${SSHUSER}:${DOC_DESTINATION}"
$ECHO $SSH "cd ${DOC_DESTINATION} && \
            unzip ${DOC_ZIP_FILE} && \
            rm -f ${DOC_ZIP_FILE}"
