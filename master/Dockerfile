FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive

# Install systemd and packages
RUN apt update && apt install -y \
    systemd \
    systemd-sysv \
    ansible \
    openssh-client \
    openssh-server \
    python3 \
    sudo \
    vim \
    nano \
    sshpass \
    iputils-ping \
    dnsutils \
    net-tools \
    curl \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configure systemd - remove unnecessary services
RUN cd /lib/systemd/system/sysinit.target.wants/ && \
    ls | grep -v systemd-tmpfiles-setup | xargs rm -f && \
    rm -f /lib/systemd/system/multi-user.target.wants/* && \
    rm -f /etc/systemd/system/*.wants/* && \
    rm -f /lib/systemd/system/local-fs.target.wants/* && \
    rm -f /lib/systemd/system/sockets.target.wants/*udev* && \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl* && \
    rm -f /lib/systemd/system/basic.target.wants/* && \
    rm -f /lib/systemd/system/anaconda.target.wants/*

# Disable systemd features that block login
RUN systemctl mask systemd-logind.service && \
    systemctl mask getty.target && \
    rm -f /usr/lib/tmpfiles.d/systemd-nologin.conf

RUN mkdir /var/run/sshd

# Create ansible user with proper groups
RUN useradd -m -s /bin/bash ansible && \
    echo "ansible:ansible" | chpasswd && \
    usermod -aG sudo ansible && \
    echo "ansible ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Create ansible directory
RUN mkdir -p /ansible && \
    chown ansible:ansible /ansible && \
    chmod 755 /ansible

# Configure SSH
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    echo "UsePAM yes" >> /etc/ssh/sshd_config

# Enable SSH service
RUN systemctl enable ssh

WORKDIR /ansible

EXPOSE 22

VOLUME ["/sys/fs/cgroup"]

STOPSIGNAL SIGRTMIN+3

CMD ["/lib/systemd/systemd"]
