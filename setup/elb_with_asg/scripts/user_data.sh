#!/bin/bash

# Get database credentials from parameter store

DBUSER=$(aws ssm get-parameters --region us-west-2 --names "django-test-app-db-username" --query "Parameters[0].Value" --output text)
DBPASSWORD=$(aws ssm get-parameters --region us-west-2 --names "django-test-app-db-password" --query "Parameters[0].Value" --output text)
DBHOST=$(aws ssm get-parameters --region us-west-2 --names "django-test-app-db-host" --query "Parameters[0].Value" --output text)

# Create uwsgi systemd configuration file

echo "
[Unit]
Description=uWSGI Service

[Service]
ExecStartPre=/bin/bash -c 'mkdir -p /run/uwsgi/ && source /home/ubuntu/.env/bin/activate && python3 /usr/src/django-test-app/backend/manage.py makemigrations && python3 /usr/src/django-test-app/backend/manage.py migrate'
ExecStart=/usr/local/bin/uwsgi --ini /usr/src/django-test-app/backend/uwsgi.ini
Restart=always
KillSignal=SIGQUIT
Type=notify
NotifyAccess=all
Environment="DBHOST=$DBHOST"
Environment="DBNAME=taskmanagerdb"
Environment="DBPASSWORD=$DBPASSWORD" 
Environment="DBPORT=5432"
Environment="DBUSER=$DBUSER"

[Install]
WantedBy=multi-user.target
" >> /etc/systemd/system/uwsgi.service 

# Initialize and start required services 

systemctl daemon-reload
systemctl start uwsgi
systemctl start nginx 
