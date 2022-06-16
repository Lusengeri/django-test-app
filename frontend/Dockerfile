FROM node:17.9.0 as dev

WORKDIR /usr/src/django-test-app/frontend

COPY package.json .

RUN ["yarn", "install"]

COPY . .

RUN ["yarn", "build"]

FROM nginx:alpine

COPY --from=dev /usr/src/django-test-app/frontend/build /usr/share/nginx/html
