pipeline {
    triggers {
        // Poll SCM - перевіряти Git репозиторій кожні 2 хвилини на предмет змін
        pollSCM('H/2 * * * *')
        // Build periodically - альтернативний варіант (закоментований)
        // cron('H/5 * * * *')
    }
    
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    imagePullPolicy: Always
    command:
    - /busybox/cat
    tty: true
    volumeMounts:
    - name: docker-config
      mountPath: /kaniko/.docker
  - name: git
    image: bitnami/git:latest
    command:
    - /bin/sh
    tty: true
  volumes:
  - name: docker-config
    configMap:
      name: docker-config
"""
        }
    }

    environment {
        AWS_REGION = 'eu-central-1'
        ECR_REPOSITORY = '045552220539.dkr.ecr.eu-central-1.amazonaws.com/dev-lesson-5-app'
        IMAGE_TAG = "django-${env.BUILD_NUMBER}"
        HELM_CHART_PATH = 'charts/django-app/values.yaml'
        GIT_REPO = 'https://github.com/IYgit/lesson-8-9.git'
        GIT_BRANCH = 'main'
    }

    stages {
        stage('Check Branch') {
            steps {
                script {
                    echo "Current branch: ${env.GIT_BRANCH}"
                    echo "Build triggered for: ${env.BRANCH_NAME ?: 'main'}"
                    
                    // Виконувати білд тільки для main гілки
                    if (env.BRANCH_NAME && env.BRANCH_NAME != 'main') {
                        echo "Skipping build for branch: ${env.BRANCH_NAME}"
                        currentBuild.result = 'ABORTED'
                        error('Build skipped for non-main branch')
                    }
                }
            }
        }
        
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    // Отримуємо короткий хеш коміту для тегу
                    env.GIT_COMMIT_SHORT = sh(
                        script: 'git rev-parse --short HEAD',
                        returnStdout: true
                    ).trim()
                    env.IMAGE_TAG = "django-${env.BUILD_NUMBER}-${env.GIT_COMMIT_SHORT}"
                }
            }
        }

        stage('Build and Push to ECR') {
            steps {
                container('kaniko') {
                    script {
                        sh """
                            echo 'Building Docker image with tag: ${IMAGE_TAG}'
                            /kaniko/executor \
                                --context `pwd` \
                                --dockerfile `pwd`/Dockerfile \
                                --destination ${ECR_REPOSITORY}:${IMAGE_TAG} \
                                --destination ${ECR_REPOSITORY}:latest
                        """
                    }
                }
            }
        }

        stage('Update Helm Chart') {
            steps {
                container('git') {
                    withCredentials([usernamePassword(
                        credentialsId: 'github-credentials',
                        usernameVariable: 'GIT_USERNAME',
                        passwordVariable: 'GIT_PASSWORD'
                    )]) {
                        script {
                            sh """
                                # Налаштування Git
                                git config --global user.email 'jenkins@cicd.local'
                                git config --global user.name 'Jenkins CI/CD'
                                git config --global --add safe.directory /home/jenkins/agent/workspace/*
                                
                                # Оновлюємо values.yaml з новим тегом
                                sed -i 's/tag: .*/tag: ${IMAGE_TAG}/' ${HELM_CHART_PATH}
                                
                                # Перевіряємо зміни
                                git diff ${HELM_CHART_PATH}
                                
                                # Додаємо та коммітимо зміни
                                git add ${HELM_CHART_PATH}
                                git commit -m "Update image tag to ${IMAGE_TAG} - Build #${BUILD_NUMBER}" || echo "No changes to commit"
                                
                                # Налаштовуємо remote URL з credentials
                                git remote set-url origin https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/IYgit/lesson-8-9.git
                                
                                # Пушимо зміни в main
                                git push origin HEAD:${GIT_BRANCH}
                            """
                        }
                    }
                }
            }
        }

        stage('Deploy with ArgoCD') {
            steps {
                script {
                    echo "Image ${IMAGE_TAG} pushed to ECR successfully"
                    echo "Helm chart updated and pushed to Git"
                    echo "ArgoCD will automatically sync the changes"
                    
                    // Можна додати перевірку статусу ArgoCD
                    sh """
                        echo "Build completed successfully!"
                        echo "Image: ${ECR_REPOSITORY}:${IMAGE_TAG}"
                        echo "Chart updated in: ${HELM_CHART_PATH}"
                    """
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed!'
        }
        success {
            echo 'Pipeline succeeded! Image built and chart updated.'
        }
        failure {
            echo 'Pipeline failed! Check the logs.'
        }
    }
}
