#!/bin/bash

sudo service nginx restart
source /home/ubuntu/.env/bin/activate

cd /home/ubuntu/django-test-app/backend/
uwsgi --ini /home/ubuntu/django-test-app/backend/django-test-app.ini &

sudo chown ubuntu:www-data /home/ubuntu/django-test-app/backend/django-test-app.sock
