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
# this one is run only once and generates a static HTML page. The script will 
# output on stdout - redirect the output to a file in the wanted folder.
#
# CLI parameters:
# 1): Source folder, where the TC packages are present. Does not need to be the final deploy folder but
#     all packages with their final names have to be there
# 2): Deploy path: the absolute linux web server path where the packages are or will be deployed, or
#     the eploy path relative to the web server root (/home/data/httpd/download.eclipse.org)
# 3): Release Title, e.g. "Trace Compass Latest Stable Version" or "Trace Compass Release x.y.z""
#
# Usage examples:
# 1) Let's say all packages for a release are in a folder "./a"
# $ ./generate_download_page.sh ./a /home/data/httpd/download.eclipse.org/tracecompass/releases/10.1.0/rcp/ "Trace Compass Release 10.1.0" > ./a/index.html
# This is equivalent:
# $ ./generate_download_page.sh ./a /tracecompass/releases/10.1.0/rcp/ "Trace Compass Release 10.1.0" > ./a/index.html
#
# Note: file ./a/index.html would need to be transferred to the release folder, along-with the packages
#
# 2) running the script from the release folder
# $ cd /home/data/httpd/download.eclipse.org/tracecompass/releases/10.1.0/rcp/ 
# $ /path/to/script/generate_download_page.sh . /home/data/httpd/download.eclipse.org/tracecompass/releases/10.1.0/rcp/ "Trace Compass Release 10.1.0" > ./index.html
# This should be equivalent:
# $ cd /home/data/httpd/download.eclipse.org/tracecompass/releases/10.1.0/rcp/ 
# $ /path/to/script/generate_download_page.sh . $PWD "Trace Compass Release 10.1.0" > ./index.html

# examples of web server path vs linux path: 
# web server deploy path: 
# tracecompass/stable/rcp/trace-compass-10.1.0-20240918-1731-linux.gtk.x86_64.tar.gz
# Linux path: 
# /home/data/httpd/download.eclipse.org/tracecompass/stable/rcp/trace-compass-10.1.0-20240918-1731-linux.gtk.x86_64.tar.gz

set -u # run with unset flag error so that missing parameters cause build failure
set -e # error out on any failed commands
set -x # echo all commands used for debugging purposes

src_dir=$1
deploy_path=$2
title=$3
downloadPrefix="https://download.eclipse.org"
base_deploy_path="/home/data/httpd/download.eclipse.org"
# if deploy path is absolute, shave it off
www_deploy_path="${deploy_path#"$base_deploy_path"}"
bg_img=https://github.com/eclipse-tracecompass/org.eclipse.tracecompass/blob/master/rcp/org.eclipse.tracecompass.rcp.branding/icons/png/tc_icon_256x256.png?raw=true

# echo "Base: $base_deploy_path"
# echo "Relative: $www_deploy_path"

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
</style>
</head>

<!-- Main page -->
<body>
<h1>$title</h1>
<table>
<tr><th>Downloads:</th></tr>
EOF

# Find release files
files=($(find $src_dir -maxdepth 1 \( -type f \) -not -name "config.php" -not -name "index.*" | sort))

# Loop through files, generate a table entry for each one
for file in "${files[@]}"; do
    filename=$(basename $file)
    size=$(du -h "$file" | awk '{print $1}')
    # Something to try... It might work to rely on the browser's context, 
    # and omit the server and path completely - after all the browser will 
    # already need to know these things to load the generated page. It this 
    # does not work, we can use the longer version below.
    echo "<tr><td><a href=\"$filename\">$filename</a> ($size)</td></tr>"
    # alternative, with server and deploy path: 
    # echo "<tr><td><a href=\"${downloadPrefix}${www_deploy_path}${filename}\">$filename</a> ($size)</td></tr>"
done

cat <<EOF
</table>
</body>
</html>
EOF
