#!/bin/bash
set -e

REPO_URL="https://github.com/vankad24/3x-ui-auto-setup.git"   # <-- укажи реальный URL репозитория
TARGET_DIR="/var/www/3x-ui-auto-setup"
ENV_FILE="$TARGET_DIR/.env"

# Проверяем существование директории
if [ ! -d "$TARGET_DIR" ]; then
    echo "Директория $TARGET_DIR не найдена. Клонирую репозиторий..."
    # Создаём родительскую директорию на случай, если /var/www отсутствует
    mkdir -p "$(dirname "$TARGET_DIR")"
    git clone "$REPO_URL" "$TARGET_DIR"
fi


if [ ! -s "$ENV_FILE" ]; then
    # Спрашиваем имя сервера
    read -rp "Введите имя сервера: " SERVER_NAME
    # Простая валидация — не пустое
    if [ -z "$SERVER_NAME" ]; then
        echo "Ошибка: имя сервера не может быть пустым." >&2
        exit 1
    fi
    # Пишем .env
    echo "SERVER_NAME=\"$SERVER_NAME\"" > "$ENV_FILE"
    echo "Записан $ENV_FILE:"
    cat "$ENV_FILE"
fi


cd "$TARGET_DIR"
echo "Начинаю установку nginx"
sh ./setup-nginx.sh

echo "Начинаю установку 3x-ui"
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
