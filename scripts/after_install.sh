#!/bin/bash

echo "Starting 'after_install.sh'..." >> /home/ubuntu/debug.log

cd /home/ubuntu/

# Set up the Python virtual environment
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

# Set-up nginx site configuration file
sudo sed -i 's/<my_ip_address>/'${MY_IP}'/' /home/ubuntu/django-test-app/django-test-app.conf
sudo cp /home/ubuntu/django-test-app/django-test-app.conf /etc/nginx/sites-available/django-test-app.conf
sudo ln -s /etc/nginx/sites-available/django-test-app.conf /etc/nginx/sites-enabled/django-test-app.conf 

echo "Completed 'after_install.sh'" >> /home/ubuntu/debug.log
