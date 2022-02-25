#!/bin/env bash

# Install the dependencies
sudo apt update
sudo apt install python3-dev gcc python3-distutils python3-pip python3-venv nginx -y

cd /home/ubuntu/
git clone https://github.com/Lusengeri/django-test-app

python3 -m venv .env
source /home/ubuntu/.env/bin/activate

# Setup django application dependencies
pip3 install wheel 
pip3 install uwsgi
pip3 install django
pip3 install -r /home/ubuntu/django-test-app/requirements.txt

# Get IP address
MY_IP=`curl -s https://icanhazip.com`

# Change ALLOWED_HOSTS[] in settings.py to ALLOWED_HOSTS = ['<my_ip_address>']
sudo sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = \['${MY_IP}'\]/" /home/ubuntu/django-test-app/backend/backend/settings.py

# Set-up uwsgi
# Create the socket location
#sudo mkdir -p /run/uwsgi/ 
#sudo chown ubuntu:www-data /run/uwsgi/
#sudo chmod 664 /run/uwsgi/

cd /home/ubuntu/django-test-app/
uwsgi --ini /home/ubuntu/django-test-app/django-test-app.ini &

# Set-up nginx 
# And insert the IP address in nginx site configuration file
sudo rm /etc/nginx/sites-available/default
sudo rm /etc/nginx/sites-enabled/default
#sudo touch /etc/nginx/sites-available/django-test-app.conf
sudo sed -i 's/<my_ip_address>/'${MY_IP}'/' /home/ubuntu/django-test-app/django-test-app.conf
sudo cp /home/ubuntu/django-test-app/django-test-app.conf /etc/nginx/sites-available/django-test-app.conf
sudo ln -s /etc/nginx/sites-available/django-test-app.conf /etc/nginx/sites-enabled/django-test-app.conf 
sudo service nginx restart
