#!/bin/bash

# Проверка root
[ "$(id -u)" -ne 0 ] && echo "Требуется root!" && exit 1

export DEBIAN_FRONTEND=noninteractive

# Обновление и установка python3-pip в первую очередь
apt-get update -y
apt-get upgrade -y
apt-get install -y --no-install-recommends python3-pip python3-venv

# ТОЛЬКО необходимые пакеты для лабораторной работы
apt-get install -y --no-install-recommends \
    vim \
    curl \
    wget \
    nmap \
    netcat-openbsd \
    python3 \
    python3-dev \
    python3.12-venv \
    # python2.7 больше нет в Ubuntu 24.04, используем альтернативы
    python2 \
    python-is-python2 \
    redis-tools \
    smbclient \
    openjdk-21-jre-headless \
    jq \
    openssh-client \
    hydra \
    # Metasploit нужно устанавливать из внешнего репозитория
    # metasploit-framework \
    sqlmap \
    nikto

# Установка Metasploit из официального репозитория
curl -fsSL https://apt.metasploit.com/metasploit-framework.gpg.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/metasploit.gpg
echo "deb [arch=amd64] https://apt.metasploit.com/ noble main" > /etc/apt/sources.list.d/metasploit.list
apt-get update -y
apt-get install -y --no-install-recommends metasploit-framework

# Python библиотеки
python3 -m pip install --upgrade pip
python3 -m pip install --break-system-packages \
    requests \
    redis \
    boto3 \
    beautifulsoup4 \
    lxml \
    colorama \
    paramiko

# Настройка Python2 через deadsnakes PPA (если нужен именно 2.7)
apt-get install -y --no-install-recommends software-properties-common
add-apt-repository -y ppa:deadsnakes/ppa
apt-get update -y
apt-get install -y --no-install-recommends python2.7 python2.7-dev

# Установка pip для Python2
curl -fsSL https://bootstrap.pypa.io/pip/2.7/get-pip.py -o get-pip.py
python2.7 get-pip.py 2>/dev/null || echo "Не удалось установить pip для Python2.7"
rm -f get-pip.py

# Создаем символические ссылки для совместимости
ln -sf /usr/bin/python3 /usr/bin/python
ln -sf /usr/bin/pip3 /usr/bin/pip

# Создаем директории для эксплойтов
mkdir -p /opt/exploits /opt/scripts

# Создаем простые скрипты для лабораторной работы
cat > /opt/scripts/test_redis.py << 'EOF'
#!/usr/bin/env python3
import redis
import sys

def test_redis(host='172.20.0.102', port=6379):
    try:
        r = redis.Redis(host=host, port=port, decode_responses=True)
        r.ping()
        print(f"[+] Redis доступен на {host}:{port}")
        print(f"[+] Версия: {r.info('server').get('redis_version', 'unknown')}")
        return True
    except Exception as e:
        print(f"[-] Ошибка подключения к Redis: {e}")
        return False

if __name__ == "__main__":
    test_redis()
EOF

chmod +x /opt/scripts/test_redis.py

echo "Минимальный набор установлен!"

# Информация о системе
echo ""
echo "=== ИНФОРМАЦИЯ О СИСТЕМЕ ==="
python3 --version
redis-cli --version 2>/dev/null || echo "Redis CLI: установлен"
smbclient --version 2>/dev/null || echo "SMB Client: установлен"
echo "Java: $(java --version 2>/dev/null | head -1)"
echo "Nmap: $(nmap --version 2>/dev/null | head -1)"
echo ""

# Держим контейнер запущенным
echo "Контейнер продолжает работу..."
echo "Для доступа выполните: docker exec -it attacker bash"
echo "IP: 172.20.0.10"
echo ""
echo "Доступные цели:"
echo "  ActiveMQ:   172.20.0.101:61616,8161"
echo "  Redis:      172.20.0.102:6379"
echo "  MinIO:      172.20.0.103:9000,9001"
echo "  Samba:      172.20.0.104:445"
echo "  Jenkins:    172.20.0.105:8080"
echo ""
echo "Тестовые команды:"
echo "  python3 /opt/scripts/test_redis.py"
echo "  nmap -sV 172.20.0.101"
echo "  smbclient -L //172.20.0.104 -N"

# Бесконечный цикл, чтобы контейнер не завершался
tail -f /dev/null