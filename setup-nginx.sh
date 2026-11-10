#!/bin/sh

set -e

git pull

# import .env
set -a
. ./.env
set +a

# make visible for child processes
export SERVER_NAME

CONFIG_NAME="$SERVER_NAME.conf"

if command -v apt >/dev/null 2>&1; then
    echo "Detected apt. Installing packages..."
    
    sudo apt update
    sudo apt install -y nginx
	sudo systemctl enable --now nginx
	
	sudo rm -f /etc/nginx/sites-enabled/default

	sed "s/{SERVER_NAME}/$SERVER_NAME/g" nginx-config.template | sudo tee "/etc/nginx/sites-available/$CONFIG_NAME" > /dev/null
	sudo ln -sfn /etc/nginx/sites-available/$CONFIG_NAME /etc/nginx/sites-enabled/$CONFIG_NAME
	
elif command -v apk >/dev/null 2>&1; then
    echo "Detected apk. Installing packages..."
    
    sudo apk update
    sudo apk add nginx nginx-systemd certbot certbot-nginx
	sudo systemctl enable --now docker nginx
	sudo rm -f /etc/nginx/http.d/default.conf

	# add updating to cron
	# sudo cp update-sertificate.sh /etc/periodic/daily/
	
	sed "s/{SERVER_NAME}/$SERVER_NAME/g" nginx-config.template | sudo tee "/etc/nginx/http.d/$CONFIG_NAME" > /dev/null

else
    echo "Error: neither apt nor apk was found."
    exit 1
fi

sudo nginx -t && sudo systemctl reload nginx


# sudo certbot --nginx --reinstall -d "$SERVER_NAME"
# sudo certbot renew --dry-run

echo "To check https try visit: https://$SERVER_NAME"

