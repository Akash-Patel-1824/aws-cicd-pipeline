pipeline {
    agent any

    options {
        skipDefaultCheckout(true)
    }

    environment {
        DOCKER_IMAGE = 'akashpatel24/newimage'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
                echo 'Source code downloaded successfully'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build \
                        -t ${DOCKER_IMAGE}:${BUILD_NUMBER} \
                        -t ${DOCKER_IMAGE}:latest .
                '''
            }
        }

        stage('Test Docker Image') {
            steps {
                sh '''
                    set -e

                    docker rm -f aws-cicd-test || true

                    docker run -d \
                        --name aws-cicd-test \
                        -p 8081:80 \
                        ${DOCKER_IMAGE}:${BUILD_NUMBER}

                    sleep 5

                    curl -f http://localhost:8081

                    docker rm -f aws-cicd-test
                '''
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {
                    sh '''
                        set -e

                        echo "$DOCKER_PASS" | docker login \
                            -u "$DOCKER_USER" \
                            --password-stdin

                        docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                        docker push ${DOCKER_IMAGE}:latest

                        docker logout
                    '''
                }
            }
        }

        stage('Deploy to AWS EC2') {
            steps {
                sshagent(['app-server-ssh']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no ubuntu@18.209.21.133 "
                            sudo docker pull akashpatel24/newimage:latest &&
                            (sudo docker rm -f aws-cicd-app || true) &&
                            sudo docker run -d \
                                --restart unless-stopped \
                                --name aws-cicd-app \
                                -p 80:80 \
                                akashpatel24/newimage:latest
                        "
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'SUCCESS: Complete AWS CI/CD Pipeline!'
        }

        failure {
            echo 'FAILED: Check Jenkins Console Output.'
        }
    }
}
