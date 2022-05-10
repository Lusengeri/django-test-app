FROM ubuntu:focal 

ENV PYTHONUNBUFFERED 1

ENV PYTHONDONTWRITEBYTECODE 1

RUN apt-get -y update 

RUN apt-get -y install python3-dev gcc python3-distutils python3-pip libpq-dev

RUN pip3 install --upgrade pip

WORKDIR /usr/src/django-test-app/backend

COPY . .

RUN pip3 install -r requirements.txt

EXPOSE 8000

CMD ["python3", "manage.py", "runserver", "0.0.0.0:8000"]
