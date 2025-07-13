#!/bin/bash

# Django CI/CD Pipeline Script для Freestyle Jenkins Job
# Еквівалент нашого Jenkinsfile

set -e

echo "=== Django CI/CD Pipeline Started ==="
echo "Build Number: $BUILD_NUMBER"
echo "Workspace: $WORKSPACE"

# Environment variables
export AWS_REGION="eu-central-1"
export ECR_REPOSITORY="045552220539.dkr.ecr.eu-central-1.amazonaws.com/dev-lesson-5-app"
export IMAGE_TAG="django-${BUILD_NUMBER}"
export HELM_CHART_PATH="charts/django-app/values.yaml"
export GIT_REPO="https://github.com/IYgit/lesson-8-9.git"
export GIT_BRANCH="main"

# Stage 1: Checkout
echo "=== Stage 1: Checkout ==="
cd $WORKSPACE
if [ -d ".git" ]; then
    git pull origin main
else
    git clone $GIT_REPO .
fi

# Отримуємо короткий хеш коміту
GIT_COMMIT_SHORT=$(git rev-parse --short HEAD)
export IMAGE_TAG="django-${BUILD_NUMBER}-${GIT_COMMIT_SHORT}"

echo "Image tag: $IMAGE_TAG"
echo "Git commit: $GIT_COMMIT_SHORT"

# Stage 2: Build Docker image (симуляція - Kaniko недоступний в Freestyle)
echo "=== Stage 2: Build Simulation ==="
echo "Would build Docker image: $ECR_REPOSITORY:$IMAGE_TAG"
echo "Context: $WORKSPACE"
echo "Dockerfile: $WORKSPACE/Dockerfile"

# Перевіряємо чи існує Dockerfile
if [ -f "Dockerfile" ]; then
    echo "✅ Dockerfile found"
    cat Dockerfile | head -10
else
    echo "❌ Dockerfile not found"
    exit 1
fi

# Stage 3: Update Helm Chart
echo "=== Stage 3: Update Helm Chart ==="
if [ -f "$HELM_CHART_PATH" ]; then
    echo "Current values.yaml:"
    cat $HELM_CHART_PATH
    
    # Оновлюємо тег (симуляція)
    echo "Would update image tag to: $IMAGE_TAG"
    
    # Симуляція Git commit
    echo "Would commit changes with message: 'Update image tag to $IMAGE_TAG - Build #$BUILD_NUMBER'"
else
    echo "❌ Helm chart not found: $HELM_CHART_PATH"
fi

# Stage 4: Deploy Info
echo "=== Stage 4: Deploy Information ==="
echo "✅ Image would be pushed to: $ECR_REPOSITORY:$IMAGE_TAG"
echo "✅ Helm chart would be updated in: $HELM_CHART_PATH"
echo "✅ ArgoCD would automatically sync the changes"

echo "=== Pipeline Completed Successfully ==="
echo "Next steps:"
echo "1. Configure Kaniko for actual Docker build"
echo "2. Setup Git credentials for push"
echo "3. Configure ECR permissions"

# Показуємо структуру проекту
echo "=== Project Structure ==="
find . -name "*.py" -o -name "*.yaml" -o -name "Dockerfile" -o -name "Jenkinsfile" | head -20
