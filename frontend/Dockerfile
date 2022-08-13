FROM node:16.16-alpine as dev

WORKDIR /usr/src/django-test-app/frontend

COPY ./package.json ./

RUN ["yarn", "install"]

COPY . .

RUN ["yarn", "build"]

FROM nginx:alpine

COPY ./nginx/default.conf /etc/nginx/conf.d/default.conf

COPY --from=dev /usr/src/django-test-app/frontend/build /usr/share/nginx/html
