# Лабораторная работа №1 - Suricata IPS Docker Stand

## Описание

Этот проект создает тестовый стенд для Suricata IPS в Docker среде с тремя контейнерами:

- suricata: Suricata IPS система
- attacker: Kali Linux для атак
- victim: Alpine Linux как жертва

## Структура проекта

```bash
.
├── docker-compose.yml          # Основной файл оркестрации
├── suricata/
│   ├── etc/
│   │   └── suricata.yaml      # Конфигурационный файл Suricata
│   ├── rules/
│   │   └── local.rules        # Правила Suricata (блокировка ICMP, логирование HTTP)
│   ├── scripts/
│   │   ├── setup.sh           # Скрипт запуска Suricata
│   │   └── setup-iptables.sh # Скрипт настройки iptables
│   └── var/log/                # Директория для логов Suricata
└── README.md
```

## Запуск стенда

```bash
docker-compose up -d
```

## Проверка работы

### 1. Откройте shell в контейнере attacker

```bash
docker exec -it attacker bash
```

### 2. Проверьте ICMP (должен блокироваться)

```bash
ping victim
```

### 3. Проверьте HTTP (должен логироваться)

```bash
curl http://victim
```

### 4. Проверьте логи Suricata

```bash
docker exec suricata_ips cat /var/log/suricata/eve.json | jq '.'
```

## Ожидаемый результат

- ICMP пакеты от attacker к victim блокируются Suricata
- HTTP запросы от attacker к victim логируются в eve.json
- В логах eve.json должны появиться события drop для ICMP и отдельные записи для HTTP-запросов
