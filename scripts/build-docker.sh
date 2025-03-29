#!/bin/bash

# Construye y sube la imagen Docker a ECR
# Uso: ./build_docker.sh <aws_region> <ecr_repo_url>

set -e

AWS_REGION=$1
ECR_REPO_URL=$2

if [ -z "$AWS_REGION" ] || [ -z "$ECR_REPO_URL" ]; then
  echo "Uso: ./build_docker.sh <aws_region> <ecr_repo_url>"
  exit 1
fi

# Autenticarse en ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO_URL

# Construir la imagen Docker
cd ../docker
docker build -t fooocus-batch .

# Etiquetar y subir la imagen
docker tag fooocus-batch:latest $ECR_REPO_URL:latest
docker push $ECR_REPO_URL:latest

echo "Imagen construida y subida correctamente a $ECR_REPO_URL:latest"
