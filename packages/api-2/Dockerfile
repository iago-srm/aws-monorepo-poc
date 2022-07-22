FROM node:alpine

WORKDIR /app

COPY ./package*.json ./
COPY ./tsconfig.json ./
COPY ./packages/api-2/ ./packages/api-2/
COPY ./packages/common/ ./packages/common/

RUN npm i

WORKDIR /app/packages/api-2

RUN npm run build

ENV PORT=3006

EXPOSE 3006

# ENTRYPOINT ["tail", "-f", "/dev/null"]
ENTRYPOINT ["npm", "start"]
