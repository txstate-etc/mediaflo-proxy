FROM node:12-alpine as build
WORKDIR /usr/app
COPY package.json ./
RUN npm install
COPY tsconfig.json ./
COPY src src
RUN npm run build

FROM node:12-alpine
WORKDIR /usr/app
COPY package.json ./
RUN npm install --production
COPY --from=build /usr/app/lib /usr/app/lib
ENTRYPOINT [ "npm" ]
CMD [ "start" ]
