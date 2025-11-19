FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    ansible \
    openssh-client \
    python3 \
    sudo \
    vim \
    nano \
    sshpass

RUN useradd -m -s /bin/bash ansible && \
    echo "ansible ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Create ansible directory as root before switching user
RUN mkdir -p /ansible && \
    chown ansible:ansible /ansible

USER ansible
WORKDIR /home/ansible
