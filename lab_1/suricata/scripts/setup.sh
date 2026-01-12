#!/bin/bash

set -e

# Проверяем, что мы в контейнере
if [ ! -f /.dockerenv ]; then
  echo "Этот скрипт должен выполняться внутри Docker контейнера"
  exit 1
fi

fix_perms() {
    if [[ "${PGID}" ]]; then
        groupmod -o -g "${PGID}" suricata
    fi

    if [[ "${PUID}" ]]; then
        usermod -o -u "${PUID}" suricata
    fi

    chown -R suricata:suricata /etc/suricata
    chown -R suricata:suricata /var/lib/suricata
    chown -R suricata:suricata /var/log/suricata
    chown -R suricata:suricata /var/run/suricata
}

for src in /etc/suricata.dist/*; do
    filename=$(basename ${src})
    dst="/etc/suricata/${filename}"
    if ! test -e "${dst}"; then
        echo "Creating ${dst}."
        cp -a "${src}" "${dst}"
    fi
done

# Установка зависимостей
# Необходимые утилиты и библиотеки для работы Suricata и iptables.
echo "Установка зависимостей"
dnf install -y jq iptables

# Включаем фильтрацию iptables для bridge-сетей Docker
modprobe br_netfilter 2>/dev/null || true
cat > /etc/sysctl.d/99-bridge-nf.conf <<EOF
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
EOF
sysctl -p /etc/sysctl.d/99-bridge-nf.conf 2>/dev/null || true

# Настраиваем iptables для перехвата трафика
/scripts/setup-iptables.sh

# Определяем интерфейс для подсети 172.20.0.0/16
# INTERFACE=$(ip route | grep "172.20.0.0/16" | awk '{print $3}')

# # Если интерфейс не найден, используем eth0 как fallback
# if [ -z "$INTERFACE" ]; then
#   INTERFACE="eth0"
#   echo "Интерфейс для подсети 172.20.0.0/16 не найден, используем $INTERFACE"
# else
#   echo "Найден интерфейс для подсети 172.20.0.0/16: $INTERFACE"
# fi

# Запускаем Suricata через entrypoint в режиме IPS через NFQUEUE
echo "Запуск Suricata в режиме IPS через NFQUEUE"
exec /usr/bin/suricata -q 0