# Descobertas

## NPM 8 Monorepo
- Instalar uma dependência nova dentro de um projeto coloca a dependency no package.json apenas daquele projeto, mas o package-lock.json fica no root. Código da dependência no node_modules/ do root.
- Todas as apis terão acesso às dependências do node_modules/ do root, mesmo se não constarem no seu package.json (isso em ambiente de dev). Porém, ao criar a imagem Docker, as dependências não estarão lá. Para que as dependências sejam acessíveis, elas precisam estar no package.json do pacote ou do root.
- Rodar npm i dentro de um projeto instala, no node_modules/ do root, apenas as suas dependências, e não as que estão no package.json do root. Instala também o próprio projeto para ser referenciado por outros, com o seu path e nome.
- Rodar npm i no root instala, no node_modules/ do root, todas as dependências do package.json do root, os projetos e as dependências dos projetos.

## Docker
- `docker run --name api-2 -d -p 3006:3006 aws-monorepo-poc-api-2` para executar um container e pode acessá-lo.
- Login no ecr com o Docker `aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 553239741950.dkr.ecr.us-east-1.amazonaws.com`

## Github Actions