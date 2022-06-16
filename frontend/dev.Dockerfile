FROM node:17.9.0 as dev

WORKDIR /usr/src/django-test-app/frontend

COPY package.json .

RUN ["yarn", "install"]

COPY . .

CMD ["yarn", "start"]
