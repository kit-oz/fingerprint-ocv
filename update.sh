#!/bin/bash
# Скрипт обновления fingerprint-ocv
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_BIN="$SCRIPT_DIR/build/src/fingerprint-ocv"
INSTALL_PATH="/opt/fingerpp/bin/fingerpp"
BACKUP_PATH="/opt/fingerpp/bin/fingerpp.bak"

echo "=== Обновление fingerprint-ocv ==="

# Проверка что бинарник существует
if [ ! -f "$BUILD_BIN" ]; then
    echo "Ошибка: бинарник не найден: $BUILD_BIN"
    echo "Сначала выполни: ./build.sh"
    exit 1
fi

# Проверка прав root
if [ "$EUID" -ne 0 ]; then
    echo "Ошибка: нужен root для установки"
    echo "Выполни: sudo $0"
    exit 1
fi

# Остановка сервиса
echo "Остановка fprintd.service..."
systemctl stop fprintd.service || true

# Бэкап
echo "Создание бэкапа..."
cp "$INSTALL_PATH" "$BACKUP_PATH"
echo "Бэкап: $BACKUP_PATH"

# Копирование нового бинарника
echo "Копирование нового бинарника..."
cp "$BUILD_BIN" "$INSTALL_PATH"
echo "Установлен: $INSTALL_PATH"

# Запуск сервиса
echo "Запуск fprintd.service..."
systemctl start fprintd.service

# Проверка статуса
sleep 2
if systemctl is-active --quiet fprintd.service; then
    echo ""
    echo "=== Успешно обновлено ==="
    echo "Логи: journalctl -u fprintd.service -f"
else
    echo ""
    echo "=== ОШИБКА: сервис не запустился ==="
    echo "Откат на бэкап..."
    cp "$BACKUP_PATH" "$INSTALL_PATH"
    systemctl start fprintd.service
    echo "Откат выполнен. Логи:"
    journalctl -u fprintd.service --no-pager -n 50
    exit 1
fi
