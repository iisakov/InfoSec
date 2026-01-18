#!/bin/bash

echo "=== Установка инструментов для атакующей машины (Ubuntu Noble) ==="

# Обновление системы
apt-get update && apt-get upgrade -y

# Установка базовых утилит
apt-get install -y \
  vim \
  nano \
  curl \
  wget \
  git \
  htop \
  net-tools \
  iputils-ping \
  iproute2 \
  dnsutils

# Установка инструментов для эксплуатации уязвимостей

# 1. Сканирование и разведка
apt-get install -y \
  nmap \
  netcat-openbsd \
  telnet

# 2. Python и инструменты разработки
apt-get install -y \
  python3 \
  python3-pip \
  python3-venv \
  python3-dev \
  python2.7 \
  python2.7-dev \
  gcc \
  make \
  libssl-dev \
  libffi-dev

# 3. Инструменты для конкретных сервисов
apt-get install -y \
  redis-tools \
  smbclient \
  openjdk-17-jre-headless \
  jq \
  awscli \
  openssh-client \
  hydra

# 4. Metasploit Framework (альтернатива для Ubuntu)
apt-get install -y \
  metasploit-framework

# 5. Дополнительные инструменты
apt-get install -y \
  file \
  sqlmap \
  nikto \
  john \
  hashcat \
  tcpdump \
  wireshark-common

# Установка Python библиотек через pip
echo "=== Установка Python библиотек ==="
pip3 install --upgrade pip
pip3 install \
  requests \
  beautifulsoup4 \
  lxml \
  colorama \
  pycryptodome \
  paramiko \
  scapy \
  pwntools \
  impacket

# Создание Python2 окружения для старых эксплойтов
echo "=== Настройка Python2 для старых эксплойтов ==="
curl -sS https://bootstrap.pypa.io/pip/2.7/get-pip.py | python2.7
pip2 install \
  virtualenv==16.7.10 \
  requests==2.27.1

# Установка эксплойтов и утилит
echo "=== Клонирование полезных репозиториев ==="
cd /opt

# Клонирование эксплойта для Samba (CVE-2017-7494)
git clone https://github.com/opsxcq/exploit-CVE-2017-7494.git /opt/exploit-CVE-2017-7494

# Клонирование Vulhub эксплойтов
git clone https://github.com/vulhub/vulhub.git /opt/vulhub

# Создание удобных алиасов
echo "=== Создание алиасов ==="
cat >> ~/.bashrc << 'EOF'

# Алиасы для удобства
alias ll='ls -la'
alias cls='clear'
alias py='python3'
alias py2='python2.7'
alias msf='msfconsole'

# Быстрый переход к эксплойтам
alias cd-exploits='cd /opt/exploit-CVE-2017-7494'
alias cd-vulhub='cd /opt/vulhub'

# Проверка сетевых соединений
alias check-ports='netstat -tulpn'
alias check-ip='ip a'

EOF

# Применение изменений
source ~/.bashrc

# Настройка времени для корректных логов
apt-get install -y tzdata
ln -fs /usr/share/zoneinfo/UTC /etc/localtime
dpkg-reconfigure --frontend noninteractive tzdata

# Финальная очистка
apt-get autoremove -y
apt-get clean

echo "=== Установка завершена! ==="
echo "Доступные инструменты:"
echo "- nmap, netcat, telnet"
echo "- Python 3.x и 2.7"
echo "- Metasploit Framework"
echo "- Redis, SMB, SSH клиенты"
echo "- Эксплойт для SambaCry в /opt/exploit-CVE-2017-7494"
echo ""
echo "Для начала работы выполните:"
echo "docker exec -it attacker bash"
echo "source ~/.bashrc"