echo "Creating key and certificate"
sudo mkdir /etc/nginx/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/rollfindr.key -out /etc/nginx/ssl/rollfindr.crt
