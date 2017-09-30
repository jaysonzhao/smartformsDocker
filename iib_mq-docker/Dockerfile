# Dockerfile for installing iib alongside MQ

FROM ubuntu:14.04

MAINTAINER Peter Weismann Peter.Weismann@yandex.com

# Update repository, install curl, bash, bc, rpm, tar packages
RUN apt-get update && \
    apt-get install -y curl bash bc rpm tar && \
    rm -rf /var/lib/apt/lists/*

# Copy startup script which invokes the MQ & IIB startup scripts and make it executable
COPY execute_startup_scripts.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/execute_startup_scripts.sh

LABEL maintainer "Arthur Barr <arthur.barr@uk.ibm.com>, Rob Parker <PARROBE@uk.ibm.com>"

LABEL "ProductID"="98102d16795c4263ad9ca075190a2d4d" \
      "ProductName"="IBM MQ Advanced for Developers" \
      "ProductVersion"="9.0.3"

# The URL to download the MQ installer from in tar.gz format
ARG MQ_URL=http://192.168.2.173:8081/mqadv_dev903_ubuntu_x86-64.tar.gz

# The MQ packages to install
ARG MQ_PACKAGES="ibmmq-server ibmmq-java ibmmq-jre ibmmq-gskit ibmmq-web ibmmq-xrservice ibmmq-msg-.*"

RUN export DEBIAN_FRONTEND=noninteractive \
  # Install additional packages required by MQ, this install process and the runtime scripts
  && apt-get update -y \
  && apt-get install -y --no-install-recommends \
    bash \
    bc \
    ca-certificates \
    coreutils \
    curl \
    debianutils \
    file \
    findutils \
    gawk \
    grep \
    libc-bin \
    lsb-release \
    mount \
    passwd \
    procps \
    sed \
    tar \
    util-linux \
  # Download and extract the MQ installation files
  && mkdir -p /tmp/mq \
  && cd /tmp/mq \
  && curl -LO $MQ_URL \
  && tar -zxvf ./*.tar.gz \
  # Recommended: Create the mqm user ID with a fixed UID and group, so that the file permissions work between different images
  && groupadd --gid 1000 mqm \
  && useradd --uid 1000 --gid mqm mqm \
  && usermod -G mqm root \
  && cd /tmp/mq/DebianMQServer \
  # Accept the MQ license
  && ./mqlicense.sh -text_only -accept \
  && echo "deb [trusted=yes] file:/tmp/mq/DebianMQServer ./" > /etc/apt/sources.list.d/IBM_MQ.list \
  # Install MQ using the DEB packages
  && apt-get update \
  && apt-get install -y $MQ_PACKAGES \
  # Remove 32-bit libraries from 64-bit container
  && find /opt/mqm /var/mqm -type f -exec file {} \; \
    | awk -F: '/ELF 32-bit/{print $1}' | xargs --no-run-if-empty rm -f \
  # Remove tar.gz files unpacked by RPM postinst scripts
  && find /opt/mqm -name '*.tar.gz' -delete \
  # Recommended: Set the default MQ installation (makes the MQ commands available on the PATH)
  && /opt/mqm/bin/setmqinst -p /opt/mqm -i \
  # Clean up all the downloaded files
  && rm -f /etc/apt/sources.list.d/IBM_MQ.list \
  && rm -rf /tmp/mq \
  # Apply any bug fixes not included in base Ubuntu or MQ image.
  # Don't upgrade everything based on Docker best practices https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/#run
  && apt-get upgrade -y libkrb5-26-heimdal \
  && apt-get upgrade -y libexpat1 \
  # End of bug fixes
  && rm -rf /var/lib/apt/lists/* \
  # Optional: Update the command prompt with the MQ version
  && echo "mq:$(dspmqver -b -f 2)" > /etc/debian_chroot \
  && rm -rf /var/mqm \
  # Optional: Set these values for the Bluemix Vulnerability Report
  && sed -i 's/PASS_MAX_DAYS\t99999/PASS_MAX_DAYS\t90/' /etc/login.defs \
  && sed -i 's/PASS_MIN_DAYS\t0/PASS_MIN_DAYS\t1/' /etc/login.defs \
  && sed -i 's/password\t\[success=1 default=ignore\]\tpam_unix\.so obscure sha512/password\t[success=1 default=ignore]\tpam_unix.so obscure sha512 minlen=8/' /etc/pam.d/common-password

COPY *.sh /usr/local/bin/
COPY *.mqsc /etc/mqm/
COPY admin.json /etc/mqm/

COPY mq-dev-config /etc/mqm/mq-dev-config

RUN chmod +x /usr/local/bin/*.sh
  
# IIB: Copy all needed scripts to image and make them executable
COPY IIB/kernel_settings.sh /tmp/
COPY IIB/iib_manage.sh /usr/local/bin/
COPY IIB/iib_config.sh /usr/local/bin/
COPY IIB/iib-license-check.sh /usr/local/bin/
COPY IIB/iib_env.sh /usr/local/bin/
RUN chmod +x /tmp/kernel_settings.sh
RUN chmod +x /usr/local/bin/*.sh

# Install IIB V10 Developer edition
RUN mkdir /opt/ibm && \
    curl http://192.168.2.173:8081/iib-10.0.0.9.tar.gz \
    | tar zx --directory /opt/ibm --exclude='tools' && \
    /opt/ibm/iib-10.0.0.9/iib make registry global accept license silently

# Configure system
RUN echo "IIB_10:" > /etc/debian_chroot  && \
    touch /var/log/syslog && \
    chown syslog:adm /var/log/syslog && \
    /tmp/kernel_settings.sh

# Create user to run as
RUN useradd --create-home --home-dir /home/iibuser -G mqbrkrs,sudo iibuser && \
    sed -e 's/^%sudo	.*/%sudo	ALL=NOPASSWD:ALL/g' -i /etc/sudoers 

RUN usermod -a -G mqm iibuser

RUN echo "#!/bin/bash" > /home/iibuser/.bash_profile && \
	sed -e "$ a . /opt/ibm/iib-10.0.0.9/server/bin/mqsiprofile " -i /home/iibuser/.bash_profile

RUN cat /etc/sudoers > /tmp/sudoers 

# Set BASH_ENV to source mqsiprofile when using docker exec bash -c
ENV BASH_ENV=/usr/local/bin/iib_env.sh

# Expose default admin port and http port
EXPOSE 1414 4414 7080 9080 9443 40001 7800 7801 7802 7803 7804 

#USER iibuser

COPY shared-classes/*.jar /var/mqsi/shared-classes/

# Always put the MQ data directory in a Docker volume
VOLUME /var/mqm

# Run mq & iib setup scripts
ENTRYPOINT ["/bin/sh", "-c", "execute_startup_scripts.sh"]


