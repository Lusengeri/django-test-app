#!/bin/bash

# Install the general dependencies
sudo apt-get update
sudo apt-get install python3-dev gcc python3-distutils python3-pip python3-venv postgresql libpq-dev nginx awscli -y

# Upgrade pip package manager
pip3 install --upgrade pip

# Install uwsgi globally
sudo pip3 install uwsgi

# Set up the Python virtual environment
python3 -m venv /home/ubuntu/.env
source /home/ubuntu/.env/bin/activate

# Setup django application dependencies
pip3 install wheel 
pip3 install django
pip3 install -r /usr/src/django-test-app/backend/requirements.txt

# Set-up nginx site configuration file
sudo cp /usr/src/django-test-app/config/nginx.conf /etc/nginx/sites-available/django-test-app.conf
sudo ln -s /etc/nginx/sites-available/django-test-app.conf /etc/nginx/sites-enabled/django-test-app.conf 
sudo rm -f /etc/nginx/sites-enabled/default
sudo service nginx restart

# Set up uwsgi service
sudo mkdir -p /var/log/uwsgi/
sudo chown ubuntu:www-data /var/log/uwsgi/

## Ensure availability of Django static files on /static/ prefix
#for dir in /usr/src/django-test-app/backend/static/*
#do
#	ln -s "$dir" /usr/src/django-test-app/frontend/build/static/
#done
