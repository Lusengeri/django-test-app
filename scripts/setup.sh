#!/bin/bash

# Install the general dependencies
sudo apt update
sudo apt install python3-dev gcc python3-distutils python3-pip python3-venv postgresql libpq-dev nginx awscli -y

pip3 install --upgrade pip

# Install dependencies for code-deploy agent
sudo apt install ruby-full wget -y

# Move to source code directory
cd /usr/src/

# Install the CodeDeploy Agent 
EC2_AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed 's/[a-z]$//'`"
sudo wget https://aws-codedeploy-$EC2_REGION.s3.$EC2_REGION.amazonaws.com/latest/install
sudo chmod +x install
sudo ./install auto

# Clean up previous installation (if any)
sudo rm -rf /usr/src/django-test-app
sudo rm -rf /usr/src/.env
sudo rm -rf /usr/src/install

sudo rm -f /etc/nginx/sites-available/default
sudo rm -f /etc/nginx/sites-enabled/default
sudo rm -f /etc/nginx/sites-available/django-test-app.conf
sudo rm -f /etc/nginx/sites-enabled/django-test-app.conf

killall uwsgi
sudo rm -rf /var/log/uwsgi/
sudo rm -rf /run/uwsgi/

# Get database credentials from parameter store
DB_USERNAME=$(aws ssm get-parameters --region us-west-2 --names "django-test-app-db-user" --query "Parameters[0].Value" --output text)
DB_PASSWORD=$(aws ssm get-parameters --region us-west-2 --names "django-test-app-db-password" --query "Parameters[0].Value" --output text)

# Set up environment variables
# For Bash
echo "export DBUSER=$DB_USERNAME" >> /home/ubuntu/.bashrc
echo "export DBNAME=taskmanagerdb" >> /home/ubuntu/.bashrc
echo "export DBHOST=$1" >> /home/ubuntu/.bashrc
echo "export DBPASSWORD=$DB_PASSWORD" >> /home/ubuntu/.bashrc
echo "export DBPORT=5432" >> /home/ubuntu/.bashrc
echo "export DATABASE_URL=postgres://$DB_USERNAME:$DB_PASSWORD@$1:5432/taskmanagerdb" >> /home/ubuntu/.bashrc

# For other shells
sudo echo 'DBUSER="'$DB_USERNAME'"' >> /etc/environment
sudo echo 'DBNAME="taskmanagerdb"' >> /etc/environment
sudo echo 'DBHOST="'$1'"' >> /etc/environment
sudo echo 'DBPASSWORD="'$DB_PASSWORD'"' >> /etc/environment
sudo echo 'DBPORT="5432"' >> /etc/environment
sudo echo 'DATABASE_URL="postgres://'$DB_USERNAME':'$DB_PASSWORD'@'$1':5432/taskmanagerdb"' >> /etc/environment

export DBUSER=$DB_USERNAME
export DBNAME=taskmanagerdb
export DBHOST=$1
export DBPASSWORD=$DB_PASSWORD
export DBPORT=5432
export DATABASE_URL=postgres://$DB_USERNAME:$DB_PASSWORD@$1:5432/taskmanagerdb

# Clone the app repository
sudo git clone https://github.com/Lusengeri/django-test-app
sudo chown -R ubuntu:www-data /usr/src/django-test-app

# Set up the Python virtual environment
python3 -m venv /home/ubuntu/.env
source /home/ubuntu/.env/bin/activate

# Setup django application dependencies
pip3 install wheel 
pip3 install uwsgi
pip3 install django
pip3 install -r /usr/src/django-test-app/backend/requirements.txt

# Database migration
python3 /usr/src/django-test-app/backend/manage.py makemigrations
python3 /usr/src/django-test-app/backend/manage.py migrate

# Set-up nginx site configuration file
sudo cp /usr/src/django-test-app/config/nginx.conf /etc/nginx/sites-available/django-test-app.conf
sudo ln -s /etc/nginx/sites-available/django-test-app.conf /etc/nginx/sites-enabled/django-test-app.conf 
sudo service nginx restart

# Create folders for uwsgi log and socket files
sudo mkdir -p /var/log/uwsgi/
sudo chown ubuntu:www-data /var/log/uwsgi/

sudo mkdir -p /run/uwsgi/
sudo chown ubuntu:www-data /run/uwsgi/

cd /usr/src/django-test-app/backend/
uwsgi --ini /usr/src/django-test-app/backend/uwsgi.ini

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
sed -i "s/localhost:8000/$MY_DOMAIN/" /usr/src/django-test-app/frontend/src/App.js

# Move to frontend folder, install dependencies and create production build
cd /usr/src/django-test-app/frontend/
yarn install
yarn build

# Ensure availability of Django static files on /static/ prefix
for dir in /usr/src/django-test-app/backend/static/*
do
	ln -s "$dir" /usr/src/django-test-app/frontend/build/static/
done
