FROM node:lts

WORKDIR /app

COPY ./package*.json ./
COPY ./tsconfig.json ./
COPY ./packages/api-1/ ./packages/api-1/
COPY ./packages/common/ ./packages/common/

RUN npm i

WORKDIR /app/packages/api-1

RUN npm run build

ENV PORT=3006

EXPOSE 3006

# ENTRYPOINT ["tail", "-f", "/dev/null"]
ENTRYPOINT ["npm", "start"]
