#!/bin/bash

# Django CI/CD Pipeline Script - Simple Version
# No special characters, basic ASCII only

set -e

echo "Django CI/CD Pipeline Started"
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
echo "Stage 1: Checkout"
cd $WORKSPACE
if [ -d ".git" ]; then
    echo "Git repository exists, pulling latest"
    git pull origin main
else
    echo "Cloning repository"
    git clone $GIT_REPO .
fi

# Get short commit hash
GIT_COMMIT_SHORT=$(git rev-parse --short HEAD)
export IMAGE_TAG="django-${BUILD_NUMBER}-${GIT_COMMIT_SHORT}"

echo "Image tag: $IMAGE_TAG"
echo "Git commit: $GIT_COMMIT_SHORT"

# Stage 2: Check Dockerfile
echo "Stage 2: Check Dockerfile"
if [ -f "Dockerfile" ]; then
    echo "Dockerfile found"
    echo "Dockerfile content:"
    cat Dockerfile | head -5
else
    echo "ERROR: Dockerfile not found"
    exit 1
fi

# Stage 3: Check Helm Chart
echo "Stage 3: Check Helm Chart"
if [ -f "$HELM_CHART_PATH" ]; then
    echo "Helm chart found: $HELM_CHART_PATH"
    echo "Current values.yaml:"
    cat $HELM_CHART_PATH
else
    echo "WARNING: Helm chart not found: $HELM_CHART_PATH"
fi

# Stage 4: Summary
echo "Stage 4: Build Summary"
echo "SUCCESS: Pipeline completed"
echo "Image would be: $ECR_REPOSITORY:$IMAGE_TAG"
echo "Chart path: $HELM_CHART_PATH"

# Show project structure
echo "Project structure:"
find . -maxdepth 2 -type f -name "*.py" -o -name "*.yaml" -o -name "Dockerfile" | head -10

echo "Pipeline finished successfully"
