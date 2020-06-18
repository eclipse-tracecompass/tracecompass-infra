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
if [ "$#" -lt 5 ]; then
	echo "Missing arguments: deploy-rcp.sh rcpPath rcpDestination rcpSitePath rcpSiteDestination rcpPattern addSymlink"
	exit
fi

rcpPath=$1
rcpDestination=$2
rcpSitePath=$3
rcpSiteDestination=$4
rcpPattern=$5
rcpSymlink=$6

SSHUSER="genie.tracecompass@projects-storage.eclipse.org"
SSH="ssh ${SSHUSER}"
SCP="scp"

ECHO=echo
if [ "$DRY_RUN" == "false" ]; then
   ECHO=""
else
    echo Dry run of build:
fi

$ECHO ${SSH} "mkdir -p ${rcpDestination} && \
              mkdir -p ${rcpSiteDestination} && \
              rm -rf  ${rcpDestination}/* && \
              rm -rf  ${rcpSiteDestination}/*"
$ECHO $SCP ${rcpPath}/${rcpPattern} "${SSHUSER}:${rcpDestination}"
$ECHO $SCP -r ${rcpSitePath}/* "${SSHUSER}:${rcpSiteDestination}"

if [ "$rcpSymlink" == "true" ]; then
    endPattern=${#rcpPattern} - 1
    pattern=${rcpPattern:0:${endPattern}}
    rcpLinuxPath=$(basename -- $(ls ${rcpPath}/${pattern}*linux.gtk*))
    rcpMacosPath=$(basename -- $(ls ${rcpPath}/${pattern}*macosx.cocoa*))
    rcpWindowsPath=$(basename -- $(ls ${rcpPath}/${pattern}*win32.win32*))
    $ECHO ${SSH} "ln -s ${rcpDestination}/${rcpLinuxPath} ${rcpDestination}/${pattern}-latest-linux.gtk.x_86_64.tar.gz && \
                  ln -s ${rcpDestination}/${rcpMacosPath} ${rcpDestination}/${pattern}-latest-macosx.cocoa.x_86_64.tar.gz && \
                  ln -s ${rcpDestination}/${rcpWindowsPath} ${rcpDestination}/${pattern}-latest-win32.win32.x_86_64.tar.gz"
fi
