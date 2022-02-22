#!/bin/env bash

# Install the dependencies
sudo apt update
sudo apt install python3-pip python3-venv nginx uwsgi -y

cd /home/ubuntu/
git clone https://github.com/Lusengeri/django-test-app

python3 -m venv .venv
source /home/ubuntu/.env/bin/activate
pip3 install -r /home/ubuntu/django-test-app/backend/requirements.txt
