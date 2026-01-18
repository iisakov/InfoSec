#!/bin/bash

# Отключаем любые интерактивные запросы
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

# Устанавливаем локаль, чтобы не было предупреждений
ln -fs /usr/share/zoneinfo/UTC /etc/localtime
echo "LC_ALL=C.UTF-8" >> /etc/environment
echo "LANG=C.UTF-8" >> /etc/environment

# Обновление системы (полностью автоматическое)
echo "=== Обновление системы ==="
apt-get update -yq
apt-get upgrade -yq
apt-get autoremove -yq

# Установка базовых утилит
echo "=== Установка базовых утилит ==="
apt-get install -yq --no-install-recommends \
    ca-certificates \
    apt-transport-https \
    software-properties-common \
    curl \
    wget \
    gnupg \
    lsb-release

# Добавляем репозиторий Metasploit
echo "=== Добавление репозиториев ==="
curl -sSL https://apt.metasploit.com/metasploit-framework.gpg.key | gpg --dearmor > /etc/apt/trusted.gpg.d/metasploit.gpg
echo "deb [arch=amd64] https://apt.metasploit.com/ noble main" > /etc/apt/sources.list.d/metasploit.list

# Обновляем после добавления репозиториев
apt-get update -yq

# Установка всех инструментов одним списком
echo "=== Установка инструментов для атак ==="
apt-get install -yq --no-install-recommends \
    # Базовые утилиты
    vim \
    nano \
    htop \
    net-tools \
    iputils-ping \
    iproute2 \
    dnsutils \
    telnet \
    file \
    jq \
    # Сканирование и разведка
    nmap \
    netcat-openbsd \
    # Python и инструменты разработки
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    python2.7 \
    python2.7-dev \
    gcc \
    make \
    build-essential \
    libssl-dev \
    libffi-dev \
    # Инструменты для сервисов
    redis-tools \
    smbclient \
    openjdk-17-jre-headless \
    awscli \
    openssh-client \
    hydra \
    # Metasploit Framework
    metasploit-framework \
    # Дополнительные инструменты
    sqlmap \
    nikto \
    tcpdump \
    wireshark-common

# Python библиотеки
echo "=== Установка Python библиотек ==="
pip3 install --no-input --upgrade pip setuptools wheel
pip3 install --no-input \
    requests \
    beautifulsoup4 \
    lxml \
    colorama \
    pycryptodome \
    paramiko \
    scapy \
    pwntools \
    impacket \
    boto3 \
    redis

# Python2 для старых эксплойтов
echo "=== Настройка Python2 ==="
curl -sS https://bootstrap.pypa.io/pip/2.7/get-pip.py | python2.7 - 2>/dev/null
pip2 install --no-input virtualenv==16.7.10 requests==2.27.1 2>/dev/null || true

# Клонирование эксплойтов
echo "=== Загрузка эксплойтов ==="
cd /opt
git clone --depth 1 https://github.com/opsxcq/exploit-CVE-2017-7494.git 2>/dev/null || echo "Не удалось клонировать Samba эксплойт"

# Настройка окружения
echo "=== Настройка окружения ==="
cat > /root/.bashrc << 'EOF'
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
alias ll='ls -la'
alias cls='clear'
alias py='python3'
alias py2='python2.7'
alias msf='msfconsole'
alias cd-exploits='cd /opt/exploit-CVE-2017-7494 2>/dev/null || echo "Директория с эксплойтами не найдена"'
EOF

# Создаем простой скрипт для проверки установки
cat > /usr/local/bin/check-tools << 'EOF'
#!/bin/bash
echo "Проверка установленных инструментов:"
echo "-----------------------------------"
which nmap && echo "✓ nmap"
which nc && echo "✓ netcat"
which python3 && echo "✓ python3"
which python2.7 && echo "✓ python2.7"
which redis-cli && echo "✓ redis-cli"
which smbclient && echo "✓ smbclient"
which msfconsole && echo "✓ metasploit"
which java && echo "✓ java"
which aws && echo "✓ awscli"
echo "-----------------------------------"
EOF

chmod +x /usr/local/bin/check-tools

# Очистка кэша для уменьшения размера
echo "=== Очистка кэша ==="
apt-get autoremove -yq
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

echo "========================================"
echo "Установка завершена!"
echo "Для проверки инструментов: check-tools"
echo "Для доступа к контейнеру: docker exec -it attacker bash"
echo "========================================"