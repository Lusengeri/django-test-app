#FROM python:3.10
#
#WORKDIR /usr/src/django-test-app/backend
#
#COPY requirements.txt requirements.txt
#
#RUN pip install -r requirements.txt
#
#COPY . .
#
#EXPOSE 8000

#CMD ["python3", "manage.py", "runserver", "0.0.0.0:8000"]

FROM ubuntu:focal 

WORKDIR /usr/src/django-test-app/backend

COPY requirements.txt requirements.txt

RUN apt-get update && apt-get install gcc python3-dev python3-distutils python3-pip libpq-dev -y

RUN pip3 install -r requirements.txt

COPY . .

EXPOSE 8000

#CMD ["python3", "manage.py", "runserver", "0.0.0.0:8000"]
