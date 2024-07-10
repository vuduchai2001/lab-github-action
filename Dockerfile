FROM node:18-alpine As development

RUN apk update && rm -rf /var/cache/apk/*

WORKDIR /app

RUN chown node:node /app

USER node

COPY package*.json ./

RUN npm ci

COPY . ./

FROM node:18-alpine As build

WORKDIR /app

COPY --from=development /app/node_modules ./node_modules

COPY . ./

RUN npm run build

RUN npm ci --only=production && npm cache clean --force

USER node

FROM node:18-alpine As production

WORKDIR /app

COPY --from=build /app/node_modules ./node_modules

COPY --from=build /app/dist ./dist

COPY --from=build /app/package.json ./package.json

ENV NODE_ENV production

USER node

EXPOSE 3000

CMD [ "node", "dist/main.js" ]