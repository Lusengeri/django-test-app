# Django-React Test Application
This repository demonstrates various methods of deploying a Django-React application on Amazon Web Services (AWS). The deployment methods include the use of:  
- Shell Scripts
- Ansible playbooks
- Cloudformation templates

## Basic Setup
The application consists of a React frontend, a Django backend and a Postgresql database. UWSGI is used as the interface between the Django backend and an Nginx webserver. To this end appropriate configuration files for the two tools are to be found in [backend/django-test-app.ini](https://github.com/Lusengeri/django-test-app/blob/master/backend/django-test-app.ini) and [django-test-app.conf](https://github.com/Lusengeri/django-test-app/blob/master/django-test-app.conf) respectively.  

The simplest deployment makes use of a single EC2 instance in which the source code is installed along with all the application dependencies. The scripts/setup.sh file contains all the necessary instructions for this set-up. Executing the script from within a running Ubuntu EC2 instance is all that is required.

<p align="center">
  <img src="https://diagrams-and-drawings.s3.amazonaws.com/aws-architecture-diagrams/django_app_basic_setup.drawio_watermarked.png" alt="basic-setup" width="80%"/>
</p>

## Highly Available and Scalable Setup
For a highly available deployment we make use of a multi-AZ autoscaling group behind and Elastic Load Balancer. To set-up everything including the VPC, subnets, route-tables etc., a CloudFormation template ([django-test-app-template](https://github.com/Lusengeri/django-test-app/blob/master/django-test-app-template.yml)) is used. 

All the software for the application along with the necessary EC2 configuration is done using an Ansible playbook ([setup.yml](https://github.com/Lusengeri/django-test-app/blob/master/setup.yml)). The Systems Manager parameter store is used to store the database credentials required when creating as well as accessing the RDS database.

<p align="center">
  <img src="https://diagrams-and-drawings.s3.amazonaws.com/aws-architecture-diagrams/django_app_available_setup.drawio_watermarked.png" width="80%"/>
</p>
