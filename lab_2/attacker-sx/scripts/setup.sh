#!/bin/bash

# Установка ping и curl
apt update && apt install -y iputils-ping curl nmap

# Держим контейнер запущенным
nmap -sX victim
ping victim