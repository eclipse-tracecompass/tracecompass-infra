#!/usr/bin/env /bin/sh
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
[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
[ -r ${HOME}/.Xresources ] && xrdb ${HOME}/.Xresources

Xvnc ${DISPLAY} -geometry 1440x900 -depth 16 -dpi 100 -PasswordFile ${HOME}/.vnc/passwd &
sleep 2
xsetroot -solid grey
vncconfig -iconic &
xhost +
metacity --replace --sm-disable --display=${DISPLAY} &