#!/bin/bash
# Скрипт сборки fingerprint-ocv
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"

echo "=== Сборка fingerprint-ocv ==="

# Настройка
cmake -B "$BUILD_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER=gcc \
    -DCMAKE_CXX_COMPILER=g++

# Сборка
cmake --build "$BUILD_DIR" -j$(nproc)

# Показ размера бинарника
echo ""
echo "=== Бинарник собран ==="
ls -lh "$BUILD_DIR/src/fingerprint-ocv"
echo ""
echo "Для установки выполни: ./update.sh"
