#!/bin/bash

# Установка ping и curl
apt update && apt install -y iputils-ping curl

# Держим контейнер запущенным
ping victim