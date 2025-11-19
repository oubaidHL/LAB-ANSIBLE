FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive

# Install systemd and basic packages
RUN apt update && apt install -y \
    systemd \
    systemd-sysv \
    openssh-server \
    sudo \
    python3 \
    iputils-ping \
    dnsutils \
    net-tools \
    curl \
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
    rm -f /usr/lib/tmpfiles.d/systemd-nologin.conf && \
    rm -f /etc/systemd/system/systemd-user-sessions.service

# Prevent nologin file from being created
RUN mkdir -p /run/nologin.d && \
    touch /run/nologin && \
    rm -f /run/nologin

RUN mkdir /var/run/sshd

# Create ansible user with proper groups
RUN useradd -m -s /bin/bash ansible && \
    echo "ansible:ansible" | chpasswd && \
    usermod -aG sudo ansible && \
    echo "ansible ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Prepare SSH folder
RUN mkdir -p /home/ansible/.ssh \
    && chmod 700 /home/ansible/.ssh \
    && chown ansible:ansible /home/ansible/.ssh

# Configure SSH to allow login during boot
RUN echo "UsePAM yes" >> /etc/ssh/sshd_config && \
    echo "PermitRootLogin no" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# Enable SSH service
RUN systemctl enable ssh

EXPOSE 22

VOLUME ["/sys/fs/cgroup"]

STOPSIGNAL SIGRTMIN+3

CMD ["/lib/systemd/systemd"]
