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