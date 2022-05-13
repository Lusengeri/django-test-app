#!/bin/env bash

# Install the general dependencies
sudo apt update
sudo apt install python3-dev gcc python3-distutils python3-pip python3-venv postgresql libpq-dev nginx -y

# Install dependencies for code-deploy agent
sudo apt install ruby-full wget -y

# Move to home directory
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
sudo rm -rf /home/ubuntu/install

sudo rm -f /etc/nginx/sites-available/default
sudo rm -f /etc/nginx/sites-enabled/default
sudo rm -f /etc/nginx/sites-available/django-test-app.conf
sudo rm -f /etc/nginx/sites-enabled/django-test-app.conf

killall uwsgi
sudo rm -rf /var/log/uwsgi/
sudo rm -rf /run/uwsgi/

# Set up database user
#sudo -u postgres PGPASSWORD=postpass psql -U postgres -h $1 -c "create user ubuntu with encrypted password 'password'"
#sudo -u postgres PGPASSWORD=postpass psql -U postgres -h $1 -c "grant all privileges on database taskmanagerdb to ubuntu"

# Set up environment variables
echo "export DBUSER=ubuntu" >> /home/ubuntu/.bashrc
echo "export DBNAME=taskmanagerdb" >> /home/ubuntu/.bashrc
echo "export DBHOST=$1" >> /home/ubuntu/.bashrc
echo "export DBPASSWORD=password" >> /home/ubuntu/.bashrc
echo "export DBPORT=5432" >> /home/ubuntu/.bashrc
echo "export DATABASE_URL=postgresql://ubuntu:password@$1:5432/taskmanagerdb" >> /home/ubuntu/.bashrc

source /home/ubuntu/.bashrc

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
pip3 install -r /home/ubuntu/django-test-app/backend/requirements.txt

# Database migration
python3 /home/ubuntu/django-test-app/backend/manage.py makemigrations
python3 /home/ubuntu/django-test-app/backend/manage.py migrate

# Set-up nginx site configuration file
sudo cp /home/ubuntu/django-test-app/django-test-app.conf /etc/nginx/sites-available/django-test-app.conf
sudo ln -s /etc/nginx/sites-available/django-test-app.conf /etc/nginx/sites-enabled/django-test-app.conf 
sudo service nginx restart

# Create folders for uwsgi log and socket files
sudo mkdir -p /var/log/uwsgi/
sudo chown ubuntu:www-data /var/log/uwsgi/

sudo mkdir -p /run/uwsgi/
sudo chown ubuntu:www-data /run/uwsgi/

cd /home/ubuntu/django-test-app/backend/
uwsgi --ini /home/ubuntu/django-test-app/backend/django-test-app.ini

sudo chown ubuntu:www-data /run/uwsgi/django-test-app.sock

# Set-up React front-end
# Install nodejs
curl -fsSL https://deb.nodesource.com/setup_17.x | sudo -E bash -
sudo apt install nodejs -y

# Install Yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update
sudo apt install --no-install-recommends yarn -y

# Get current IP address of running server
#MY_IP=`curl -s https://icanhazip.com`
MY_DOMAIN=$2

# Set base url for production environment
sudo sed -i "s/localhost:8000/${MY_DOMAIN}/" /home/ubuntu/django-test-app/frontend/src/App.js

# Move to frontend folder, install dependencies and create production build
cd /home/ubuntu/django-test-app/frontend/
yarn install
yarn build

# Ensure availability of Django static files on /static/ prefix
for dir in /home/ubuntu/django-test-app/backend/static/*
do
	ln -s "$dir" /home/ubuntu/django-test-app/frontend/build/static/
done
