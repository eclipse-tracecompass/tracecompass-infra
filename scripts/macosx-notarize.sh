#!/usr/bin/env /bin/bash
#*******************************************************************************
# Copyright (c) 2019, 2023 IBM Corporation and others.
#
# This program and the accompanying materials
# are made available under the terms of the Eclipse Public License 2.0
# which accompanies this distribution, and is available at
# https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#     Sravan Kumar Lakkimsetti - initial API and implementation
#     Jonah Graham - adapted for the EPP project (used https://git.eclipse.org/c/platform/eclipse.platform.releng.aggregator.git/tree/cje-production/scripts/common-functions.shsource?id=8866cc6db76d777751acb56456b248708dd80eda#n47 as source)
#     Marc Dumais - adapted for the Trace Compass project (used https://github.com/eclipse-packaging/packages/blob/9282c079339625bac45c0eb394f72f8b8b5a8d5a/releng/org.eclipse.epp.config/tools/macosx-notarization-single.sh as source, as well as this EPP Jenkins job configuration: https://ci.eclipse.org/packaging/job/notarize-downloads/configure)

set -u # run with unset flag error so that missing parameters cause build failure
set -x # echo all commands used for debugging purposes

##
# Notatize all .dmg files found in the "RCP_DESTINATION" folder, that's assumed to
# reside on the "download" server.  They need to be transfered to the Jenkins workspace
# first, and put back to the release folder at the end.

RCP_DESTINATION=$1

SSHUSER="genie.tracecompass@projects-storage.eclipse.org"
SSH="ssh ${SSHUSER}"
SCP="scp"

# Notatize a single "DMG" file passed as an argument. Uses current directory as a temporary directory
function notarize_single_dmg() {
    DMG_FILE="$1"
    DMG="$(basename "${DMG_FILE}")"
    # keep a copy of the original dmg
    cp "${DMG_FILE}" "${DMG_FILE}-notnotarized"
    cp "${DMG_FILE}" "${DMG}"

    # Prior to Mac M1 the primary bundle ID used was the name of the package with platform info stripped.
    # However, the ID seems to be allowed to be arbitrary, therefore use the full file name so that
    # aarch an x86_64 make the id unique. Except that it appears that _ is not permitted.
    # See https://developer.apple.com/forums/thread/120421
    PRIMARY_BUNDLE_ID="$(echo ${DMG} | sed 's/_/-/g')"

    retryCount=1
    while [ ${retryCount} -gt 0 ]; do
        RESPONSE_RAW=$(curl --write-out "\n%{http_code}" -s -X POST -F file=@${DMG} -F 'options={"primaryBundleId": "'${PRIMARY_BUNDLE_ID}'", "staple": true};type=application/json' https://cbi.eclipse.org/macos/xcrun/notarize)
        RESPONSE=$(head -n1 <<<"${RESPONSE_RAW}")
        STATUS_CODE=$(tail -n1 <<<"${RESPONSE_RAW}")
        UUID="$(echo "${RESPONSE}" | jq -r '.uuid')"
        STATUS="$(echo "${RESPONSE}" | jq -r '.notarizationStatus.status')"

        if [[ ${STATUS_CODE} == '503' || ${STATUS_CODE} == '502' ]]; then
            echo Initial upload failed, Retrying
        else
            while [[ ${STATUS} == 'IN_PROGRESS' || ${STATUS_CODE} == '503' || ${STATUS_CODE} == '502' ]]; do
                sleep 1m
                RESPONSE_RAW=$(curl --write-out "\n%{http_code}" -s https://cbi.eclipse.org/macos/xcrun/${UUID}/status)
                RESPONSE=$(head -n1 <<<"${RESPONSE_RAW}")
                STATUS_CODE=$(tail -n1 <<<"${RESPONSE_RAW}")
                STATUS=$(echo ${RESPONSE} | jq -r '.notarizationStatus.status')
            done
        fi

        if [[ ${STATUS} != 'COMPLETE' ]]; then
            echo "Notarization failed: ${RESPONSE}"
            retryCount=$(expr $retryCount - 1)
            if [ $retryCount -eq 0 ]; then
                echo "Notarization failed. Exiting"
                exit 1
            else
                echo "Retrying..."
            fi
        else
            break
        fi

    done

    rm "${DMG}"
    curl -JO https://cbi.eclipse.org/macos/xcrun/${UUID}/download
    cp -vf "${DMG}" "${DMG_FILE}"
}

# Main script

# fetch dmg files from download server/area
mkdir temp
pushd temp
for path in $(${SSH} find ${RCP_DESTINATION} -maxdepth 1 -name '*.dmg'); do
    ${SCP} ${SSHUSER}:${path} .
done
popd

# notarize each dmg files
for i in $(find ./temp -name '*.dmg'); do
    LOG=$(basename ${i}).log
    echo "Starting ${i}" >>${LOG}
    notarize_single_dmg ${i} |& tee --append ${LOG} &
    sleep 18s # start jobs at a small interval from each other
done

jobs -p
wait < <(jobs -p)

# upload dmg files (including original "-notnotarized" file) to their release folder
pushd temp
for i in $(find * -name '*.dmg'); do
    ${SCP} ${i}* ${SSHUSER}:${RCP_DESTINATION}
done
popd

