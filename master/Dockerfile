FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
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
    curl

RUN useradd -m -s /bin/bash ansible && \
    echo "ansible ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "ansible:ansible" | chpasswd

# Create ansible directory as root before switching user
RUN mkdir -p /ansible && \
    chown ansible:ansible /ansible && \
    chmod 755 /ansible

# Configure SSH
RUN mkdir /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

EXPOSE 22

# Start SSH service and keep container running
CMD ["/usr/sbin/sshd", "-D"]
