FROM ubuntu:latest

# Remove user needed interactions
ENV DEBIAN_FRONTEND noninteractive

# First update and required packages
RUN apt-get update && \
    apt-get install -y openssh-server git curl software-properties-common ca-certificates gnupg sudo vim

RUN systemctl enable ssh.service

RUN useradd -m -d /home/dev -s /bin/bash dev && \
    mkdir -p /var/run/sshd && \
    mkdir -p /home/dev/sync && \
    mkdir -p /home/dev/.ssh && \
    touch authorized_keys

RUN echo 'dev ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/dev && \
    chmod 440 /etc/sudoers.d/dev

RUN echo "ssh-public-key" > /home/dev/.ssh/authorized_keys

RUN chmod 600 /home/dev/.ssh/authorized_keys && \
    chown -R dev:dev /home/dev/.ssh

RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

EXPOSE 22 80 443

CMD ["/usr/sbin/sshd", "-D"]

