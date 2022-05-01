#!/bin/env bash

# Install the general dependencies
sudo apt update
sudo apt install python3-dev gcc python3-distutils python3-pip python3-venv postgresql libpq-dev nginx -y

# Install dependencies for code-deploy agent
sudo apt install ruby-full wget -y

cd /home/ubuntu/

# Install the CodeDeploy Agent 
EC2_AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed 's/[a-z]$//'`"
wget https://aws-codedeploy-$EC2_REGION.s3.$EC2_REGION.amazonaws.com/latest/install
chmod +x install
sudo ./install auto

# Clean up previous installation (if any)
sudo rm -rf /home/ubuntu/django-test-app
sudo rm -rf /home/ubuntu/.env
sudo rm -f /etc/nginx/sites-available/default
sudo rm -f /etc/nginx/sites-enabled/default
sudo rm -f /etc/nginx/sites-available/django-test-app.conf
sudo rm -f /etc/nginx/sites-enabled/django-test-app.conf

# Clone the app repository
git clone https://github.com/Lusengeri/django-test-app

sudo chown -R ubuntu:www-data /home/ubuntu/django-test-app

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
#sudo sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = \['${MY_IP}'\]/" /home/ubuntu/django-test-app/backend/backend/settings.py

# Set-up nginx site configuration file
#sudo sed -i 's/<my_ip_address>/'${MY_IP}'/' /home/ubuntu/django-test-app/django-test-app.conf
sudo cp /home/ubuntu/django-test-app/django-test-app.conf /etc/nginx/sites-available/django-test-app.conf
sudo ln -s /etc/nginx/sites-available/django-test-app.conf /etc/nginx/sites-enabled/django-test-app.conf 

sudo service nginx restart

sudo mkdir -p /var/log/uwsgi/
sudo chown ubuntu:www-data /var/log/uwsgi/

cd /home/ubuntu/django-test-app/backend/
uwsgi --ini /home/ubuntu/django-test-app/backend/django-test-app.ini

sudo chown ubuntu:www-data /home/ubuntu/django-test-app/backend/django-test-app.sock

# Set-up React front-end
# Install node ppa
curl -fsSL https://deb.nodesource.com/setup_17.x | sudo -E bash -
sudo apt install nodejs -y

# Set up Yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update
sudo apt install --no-install-recommends yarn -y

# Move to frontend folder and install dependencies
cd /home/ubuntu/django-test-app/frontend/

# Set base url for production environment
sudo sed -i "s/localhost:8000/${MY_IP}/" /home/ubuntu/django-test-app/frontend/src/App.js

yarn install
yarn build

sudo cp -r /home/ubuntu/django-test-app/frontend/build/* /var/www/

for dir in /home/ubuntu/django-test-app/backend/static/*
do
	ln -s "$dir" /var/www/static/
done
