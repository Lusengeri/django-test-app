#!/bin/bash

echo "Starting 'application_stop'..." >> /home/ubuntu/debug.log
killall uwsgi
echo "Completed 'application_stop'..." >> /home/ubuntu/debug.log
