FROM node:17.9.0

WORKDIR /usr/src/django-test-app/frontend

COPY . .

RUN yarn install

EXPOSE 3000

CMD ["yarn", "start"]
