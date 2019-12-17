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

repo="tracecompass"
if [ "$#" -lt 2 ]; then
    echo "Missing argument: usage deploy-update-site source destination"
	exit
fi

sitePath=$1
siteDestination=$2

SSHUSER="genie.tracecompass@projects-storage.eclipse.org"
SSH="ssh ${SSHUSER}"
SCP="scp"

ECHO=echo
if [ "$DRY_RUN" == "false" ]; then
   ECHO=""
else
    echo Dry run of build:
fi

$ECHO ${SSH} "mkdir -p ${siteDestination}
              rm -rf  ${siteDestination}/*"
$ECHO $SCP -r ${sitePath}/* "${SSHUSER}:${siteDestination}"
