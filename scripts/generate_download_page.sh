#!/usr/bin/env /bin/bash

###############################################################################
# Copyright (c) 2024 Ericsson
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License 2.0
# which accompanies this distribution, and is available at
# https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
###############################################################################

# Bash version of the old "rcp_index_php". Contrary to the original php script, 
# this one generates a static HTML page. The script will output on stdout - redirect 
# the output to a file to save it.
#
# CLI parameters:
# 1): a folder where the TC packages are present. Does not need to be the final
#     deploy folder but all packages with their final names have to be present
# 2): Release Title, e.g. "Trace Compass Latest Stable Version" or "Trace Compass Release x.y.z""
#
# See the various Jenkinsfile for usage examples

set -u # run with unset flag error so that missing parameters cause build failure
set -e # error out on any failed commands
set -x # echo all commands used for debugging purposes

src_dir=$1
title=$2

bg_img=https://github.com/eclipse-tracecompass/org.eclipse.tracecompass/blob/master/rcp/org.eclipse.tracecompass.rcp.branding/icons/png/tc_icon_256x256.png?raw=true

SSHUSER="genie.tracecompass@projects-storage.eclipse.org"
SSH="ssh ${SSHUSER}"
current_date=$(date +"%Y-%m-%d %H:%M:%S %Z")

# HTML header
cat <<EOF
<!doctype html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>$title</title>
<style>
    body {
        font-family: Arial, sans-serif;
        background: url('$bg_img') no-repeat center center fixed;
        background-size: contain;
        /* background-size: cover; */
    }
    h1 {
        text-align: center;
        color: #333;
    }
    table {
        width: 80%;
        margin: auto;
        background-color: rgba(255, 255, 255, 0.7);
        box-shadow: 0 4px 8px rgba(0,0,0,0.1);
    }
    th, td {
        padding: 12px;
        text-align: left;
        border-bottom: 1px solid #ddd;
    }
    tr:nth-child(even) {
        background-color: rgba(255, 255, 255, 0.7);
    }
    tr:hover {
        background-color: rgba(230,230,230,0.7);
    }
    a {
        color: #0073e6;
        text-decoration: none;
    }
    footer {
        background-color: rgba(255, 255, 255, 0.7);
        text-align: center; 
        margin: 40px; 
        font-size: 0.7em; 
    }
</style>
</head>

<!-- Main page -->
<body>
<h1>$title</h1>
<table>
<tr><th>Downloads:</th></tr>
EOF

# Find release files
files=($(${SSH} "find ${src_dir} -maxdepth 1 -type f -not -name 'config.php' -not -name 'index.*' | sort"))

# Loop through files, generate a table entry for each one
for file in "${files[@]}"; do
    filename=$(basename $file)
    size=$(${SSH} "du -h '$file' | awk '{print \$1}'")
    echo "<tr><td><a href=\"$filename\">$filename</a> ($size)</td></tr>"
done

cat <<EOF
</table>
<footer>Page generated on: $current_date</footer>
</body>
</html>
EOF
