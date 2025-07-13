pipeline {
    agent {
        kubernetes {
            label 'jenkins-agent'
            defaultContainer 'kaniko'
        }
    }

    environment {
        AWS_REGION = 'eu-central-1'
        ECR_REPOSITORY = '045552220539.dkr.ecr.eu-central-1.amazonaws.com/dev-lesson-5-app'
        IMAGE_TAG = "django-${env.BUILD_NUMBER}"
        HELM_CHART_PATH = 'charts/django-app/values.yaml'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build and Push to ECR') {
            steps {
                container('kaniko') {
                    script {
                        sh """
                            /kaniko/executor --context `pwd` --dockerfile `pwd`/Dockerfile --destination ${ECR_REPOSITORY}:${IMAGE_TAG}
                        """
                    }
                }
            }
        }

        stage('Update Helm Chart') {
            steps {
                script {
                    def values = readYaml file: HELM_CHART_PATH
                    values.image.tag = IMAGE_TAG
                    writeYaml file: HELM_CHART_PATH, data: values

                    sh "git config --global user.email 'jenkins@example.com'"
                    sh "git config --global user.name 'Jenkins'"
                    sh "git add ${HELM_CHART_PATH}"
                    sh "git commit -m 'Update image tag to ${IMAGE_TAG}'"
                    sh 'git push origin main'
                }
            }
        }
    }
}
