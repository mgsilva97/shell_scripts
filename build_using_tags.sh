#!/bin/bash

IMAGE="$1"
TAG="$2"
ACCOUNT_NUMBER="ACCOUNT-NUMBER"
REGION="us-east-1"
DOCKERFILEPATH="/home/michael/Documentos/docker/"

if [ -z "$IMAGE" ] || [ -z "$TAG" ]; 
    then
        echo "Obrigatorio o uso da TAG para gerar o Build"
        echo "Exemplo: $0 node 12-alpine"
        exit 1
fi

echo "Efetuando login no ECR..."
sleep 2

aws ecr get-login-password --region $REGION | sudo /usr/bin/docker login \
--username AWS --password-stdin "$ACCOUNT_NUMBER.dkr.ecr.$REGION.amazonaws.com/base/$IMAGE"

if [ $? -eq 0 ]; then
    echo "Login efetuado com sucesso!"
else
    echo "Erro ao realizar o login. Verifique os valores digitados e tente novamente"
    exit 1
fi

echo "Realizando o build da imagem $IMAGE:$TAG"
sleep 2

sudo /usr/bin/docker build -t base/$IMAGE:$TAG "$DOCKERFILEPATH/$IMAGE/$TAG"

if [ $? -eq 0 ]; then
    echo "Build realizado com sucesso!"
else
    echo "Erro ao realizar o build. Tente novamente"
    exit 1
fi

echo "Realizando a Tag da imagem..."
sleep 2

sudo /usr/bin/docker tag base/$IMAGE:$TAG "$ACCOUNT_NUMBER.dkr.ecr.$REGION.amazonaws.com/base/$IMAGE:$TAG"

if [ $? -eq 0 ]; then
    echo "Tag realizada com sucesso!"
else
    echo "Erro ao realizar a tag da imagem. Tente novamente"
    exit 1
fi

echo "Realizando o push para o repositorio ECR..."
sleep 2

sudo /usr/bin/docker push "$ACCOUNT_NUMBER.dkr.ecr.$REGION.amazonaws.com/base/$IMAGE:$TAG"

if [ $? -eq 0 ]; then
    echo "Push realizado com sucesso!"
    sleep 3
    echo "Verifique o repositorio ECR com as novas imagens"
else
    echo "Erro ao realizar a Push da imagem para o repositorio. Tente novamente"
    exit 1
fi