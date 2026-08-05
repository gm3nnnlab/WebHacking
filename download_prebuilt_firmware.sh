#!/bin/bash
# Script to download and integrate pre-built mayhem-firmware with MDK-Predator

set -e

RELEASE_URL="${1:-https://github.com/portapack-mayhem/mayhem-firmware/releases/download}"
OUTPUT_DIR="/tmp/mayhem-prebuilt"
PROJECT_DIR="/home/user/WebHacking/build/mdk-predator/build/mayhem-firmware/build"

echo "=== MDK-Predator Pre-built Firmware Integration ==="
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR"

echo "📥 Ось варіанти завантаження:"
echo ""
echo "1. Завантажити з GitHub (потребує посилання)"
echo "2. Використати локальний файл"
echo "3. Показати інструкцію для ручного завантаження"
echo ""
read -p "Виберіть опцію (1-3): " choice

case $choice in
  1)
    echo "Введи пряме посилання на .zip файл:"
    read -p "URL: " url
    echo "Завантажую..."
    wget -q --show-progress "$url" -O mayhem-firmware.zip
    unzip -q mayhem-firmware.zip
    ;;
  2)
    echo "Введи шлях до локального файлу:"
    read -p "Шлях: " filepath
    if [ -f "$filepath" ]; then
      cp "$filepath" mayhem-firmware.zip
      unzip -q mayhem-firmware.zip
    else
      echo "❌ Файл не знайдено: $filepath"
      exit 1
    fi
    ;;
  3)
    echo ""
    echo "📖 Ручне завантаження:"
    echo "1. Перейди на: https://github.com/portapack-mayhem/mayhem-firmware/releases"
    echo "2. Знайди найновіший релізу для PortaPack H4M"
    echo "3. Завантаж архів (наприклад mayhem_vX.X.X.zip)"
    echo "4. Витяг його в $OUTPUT_DIR"
    echo "5. Запусти цей скрипт заново з опцією 2"
    exit 0
    ;;
  *)
    echo "❌ Невідома опція"
    exit 1
    ;;
esac

# Find application.bin
echo ""
echo "🔍 Шукаю application.bin..."
APP_BIN=$(find . -name "application.bin" 2>/dev/null | head -1)

if [ -z "$APP_BIN" ]; then
  echo "❌ application.bin не знайдено"
  echo "Вміст папки:"
  ls -la
  exit 1
fi

echo "✅ Знайдено: $APP_BIN"

# Copy to project
echo ""
echo "📋 Копіюю в проект..."
cp "$APP_BIN" "$PROJECT_DIR/application.bin"
echo "✅ Скопійовано в: $PROJECT_DIR/application.bin"

# Try to find and copy .ppma files
echo ""
echo "🔍 Шукаю .ppma файли..."
PPMA_FILES=$(find . -name "*.ppma" 2>/dev/null)

if [ -n "$PPMA_FILES" ]; then
  echo "✅ Знайдено .ppma файли:"
  echo "$PPMA_FILES"
  echo ""
  echo "Копіюю у /tmp/mdk-predator-apps/"
  mkdir -p /tmp/mdk-predator-apps
  echo "$PPMA_FILES" | while read ppma; do
    cp "$ppma" /tmp/mdk-predator-apps/
  done
  echo "✅ Скопійовано в: /tmp/mdk-predator-apps/"
else
  echo "ℹ️  .ppma файли не знайдені (будуть генеруватися)"
fi

echo ""
echo "=== Готово! ==="
echo ""
echo "📋 Наступні кроки:"
echo "1. cd $PROJECT_DIR"
echo "2. Запусти export script для генерації .ppma"
echo "3. Розгорни на PortaPack H4M"
echo ""
