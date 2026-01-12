#!/bin/bash

# Настраиваем iptables для перехвата Docker-трафика
# Направляем трафик в очередь NFQUEUE (Suricata может его анализировать и при необходимости блокировать)
# Добавляем правило для перехвата трафика между контейнерами
iptables -D DOCKER-USER -j NFQUEUE --queue-num 1 --queue-bypass 2>/dev/null || true
iptables -D DOCKER-FORWARD -j NFQUEUE --queue-num 1 --queue-bypass 2>/dev/null || true
iptables -D FORWARD -j NFQUEUE --queue-num 1 --queue-bypass 2>/dev/null || true
iptables -I DOCKER-USER -j NFQUEUE --queue-num 1 --queue-bypass
iptables -I DOCKER-FORWARD -j NFQUEUE --queue-num 1 --queue-bypass
iptables -I FORWARD -j NFQUEUE --queue-num 1 --queue-bypass