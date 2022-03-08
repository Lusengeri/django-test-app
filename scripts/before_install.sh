#!/bin/bash

# Clean up / uninstall previous installation
sudo rm -rf /home/ubuntu/django-test-app
sudo rm -rf /home/ubuntu/.env
sudo rm -f /etc/nginx/sites-available/default
sudo rm -f /etc/nginx/sites-enabled/default
sudo rm -f /etc/nginx/sites-available/django-test-app.conf
sudo rm -f /etc/nginx/sites-enabled/django-test-app.conf
