echo "Removing existing enabled websites"
sudo rm -f /etc/nginx/sites-enabled/*
echo "Copying app config to nginx"
sudo cp config/external/rollfindr-nginx.conf /etc/nginx/sites-available/
echo "Enabling app"
sudo ln -sf /etc/nginx/sites-available/rollfindr-nginx.conf /etc/nginx/sites-enabled/rollfindr-nginx.conf
sudo /etc/init.d/nginx restart
