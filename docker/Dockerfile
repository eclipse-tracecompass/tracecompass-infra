###############################################################################
# Copyright (c) 2019, 2024 Ericsson.
#
# This program and the accompanying materials
# are made available under the terms of the Eclipse Public License 2.0
# which accompanies this distribution, and is available at
# https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
###############################################################################

FROM ubuntu:22.04

USER root

### user name recognition at runtime w/ an arbitrary uid - for OpenShift deployments
COPY scripts/uid_entrypoint /usr/local/bin/uid_entrypoint
RUN chmod u+x /usr/local/bin/uid_entrypoint && \
    chgrp 0 /usr/local/bin/uid_entrypoint && \
    chmod g=u /usr/local/bin/uid_entrypoint /etc/passwd
#ENTRYPOINT [ "uid_entrypoint" ]
### end

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential \
      ca-certificates \
      curl \
      git \
      gnupg \
      openssh-client \
      pkg-config \
      wget \
      zip \
      locales \
      icewm \
      x11-xserver-utils \
      libgl1-mesa-dri \
      xfonts-base \
      xfonts-scalable \
      xfonts-100dpi \
      xfonts-75dpi \
      fonts-dejavu \
      fonts-dejavu-core \
      fonts-dejavu-extra \
      python3-all-dev python3-pip python3-setuptools \
      tigervnc-tools \
      tigervnc-standalone-server \
      tigervnc-xorg-extension\
      tigervnc-viewer \
      tigervnc-common \
      metacity \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8 \
    && pip3 install --upgrade pip \
    && ln-s /usr/bin/python3 /usr/bin/python

# Need locale to be UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends x11-utils xauth libglu1-mesa x11-xkb-utils \
    && rm -rf /var/lib/apt/lists/*

ENV USER_NAME tracecompass
ENV HOME /home/tracecompass

# Setup VNC
ENV DISPLAY :0
RUN mkdir -p ${HOME}/.vnc && chmod -R 775 ${HOME} \
  && echo "123456" | vncpasswd -f > ${HOME}/.vnc/passwd \
  && chmod 600 ${HOME}/.vnc/passwd
# Create a custom vnc xstartup file
COPY scripts/xstartup_icewm.sh ${HOME}/.vnc/xstartup.sh
RUN chmod 755 ${HOME}/.vnc/xstartup.sh
ENTRYPOINT [ "uid_entrypoint" ]
CMD ["/home/tracecompass/.vnc/xstartup.sh"]

#Fix permissions for OpenShift & standard k8s
RUN chown -R 1000:0 /home/tracecompass \
  && chmod -R g+rwX /home/tracecompass

ENV _JAVA_OPTIONS="-Duser.home=/home/tracecompass"

USER 1000
WORKDIR /home/tracecompass