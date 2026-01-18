#!/bin/bash

# Проверка root
[ "$(id -u)" -ne 0 ] && echo "Требуется root!" && exit 1

export DEBIAN_FRONTEND=noninteractive

# Обновление
apt-get update -y
apt-get upgrade -y

# ТОЛЬКО необходимые пакеты для лабораторной работы
apt-get install -y --no-install-recommends \
    vim \
    curl \
    wget \
    nmap \
    netcat-openbsd \
    python3 \
    python3-pip \
    python2.7 \
    redis-tools \
    smbclient \
    openjdk-17-jre-headless \
    jq \
    openssh-client \
    metasploit-framework \
    hydra

# Python библиотеки
pip3 install --no-input --break-system-packages \
    requests \
    redis \
    boto3

echo "Минимальный набор установлен!"
echo "Контейнер продолжает работу..."
echo "Для доступа выполните: docker exec -it attacker bash"
echo "IP: 172.20.0.10"
echo "Доступные цели:"
echo "  ActiveMQ:   172.20.0.101:61616,8161"
echo "  Redis:      172.20.0.102:6379"
echo "  MinIO:      172.20.0.103:9000,9001"
echo "  Samba:      172.20.0.104:445"
echo "  Jenkins:    172.20.0.105:8080"

# Держим контейнер запущеным
tail -f /dev/null