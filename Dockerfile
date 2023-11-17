FROM ubuntu:20.04

# Remove user needed interactions
ENV DEBIAN_FRONTEND noninteractive

# First update and required packages
RUN apt-get update && \
    apt-get install -y openssh-server git curl software-properties-common ca-certificates gnupg sudo

# Install Node 16
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_16.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install nodejs -y

RUN systemctl enable ssh.service

RUN useradd -m -d /home/dev -s /bin/bash dev && \
    mkdir -p /var/run/sshd && \
    mkdir -p /home/dev/gitrepo && \
    mkdir -p /home/dev/.ssh && \
    touch authorized_keys

RUN echo 'dev ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/dev && \
    chmod 440 /etc/sudoers.d/dev

RUN echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDqvrv+5xf30m6rIO75AFJ8adbabYqfe5sbs5gpkP8kSfy2dP/LC061AoPajyZ4YW6Z+H3nc4TiGwjv5GsDEnnGHPNYO3Uk+iBzxkElHFeEsxyeaugZ//BOphyGzPYIbK9JuwSvVOuKMFodvMTSzG6/fVynDd/YKJaLQQsJSKOqMXLkFetrRRHFhljue9EQIUrIsyf6rACPBq8GR9VFkvMgunZSa0OhspeJWdagFnF3tLf5pLmjAmfHMe03bWkDxjivwnxblh3g2uWV4OuRQ59T4y/HdCNn1E4cAgUz3EH4YRzb4zs2UMR/68MuSHI35gXrH31tDNTEllD/1F6tf7KT7221vLk6KH+LgD10oulT7grVt8dya6xscpq9byqap/txmYJTUL4wezaxyu4f6Iek8KXDTQ/hHVAwLJpjM63BmOFOzAF6JmRWJdeW035UV6BQuE4Y8EGQTthxL0DwFAm0nXw20/eipdqe/4+YQlo+nEkbZVbS48qUR7uIrIZgVeM= otralongo@macbook-pro-de-olivier-1.home" > /home/dev/.ssh/authorized_keys

RUN chmod 600 /home/dev/.ssh/authorized_keys && \
    chown -R dev:dev /home/dev/.ssh

RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

EXPOSE 22 80 443 2358

CMD ["/usr/sbin/sshd", "-D"]

