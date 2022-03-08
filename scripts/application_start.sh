#!/bin/bash

sudo service nginx restart
source /home/ubuntu/.env/bin/activate

cd /home/ubuntu/django-test-app/backend/

sudo mkdir -p /var/log/uwsgi/
sudo chown ubuntu:www-data /var/log/uwsgi/

uwsgi --ini /home/ubuntu/django-test-app/backend/django-test-app.ini 
sudo chown ubuntu:www-data /home/ubuntu/django-test-app/backend/django-test-app.sock
