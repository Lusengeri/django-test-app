FROM node:16.16-alpine as dev

WORKDIR /usr/src/django-test-app/frontend

COPY package.json .

RUN ["yarn", "install"]

COPY . .

CMD ["yarn", "start"]
