#!/usr/bin/env bash
set -e
AWS_REGION="${AWS_REGION:-ap-south-1}"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_URL="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

repo="$1"    # e.g., frontend
image_tag="$2" # e.g., $GIT_COMMIT or latest

aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin ${ECR_URL}
docker build -t ${repo}:${image_tag} ./Application-Code/${repo}
docker tag ${repo}:${image_tag} ${ECR_URL}/${repo}:${image_tag}
docker push ${ECR_URL}/${repo}:${image_tag}
echo "${ECR_URL}/${repo}:${image_tag}"

