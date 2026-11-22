pipeline {
    agent any

    options {
        skipDefaultCheckout(true)
    }

    environment {
        DOCKER_IMAGE = 'akashpatel24/newimage'
        APP_SERVER_IP = '44.216.87.18'
    }

    stages {

        // Stage 1: Checkout source code from GitHub
        stage('Checkout') {
            steps {
                checkout scm
                echo 'Source code downloaded successfully'
            }
        }

        // Stage 2: Build Docker image
        stage('Build Docker Image') {
            steps {
                sh '''
                    set -e

                    docker build \
                        -t ${DOCKER_IMAGE}:${BUILD_NUMBER} \
                        -t ${DOCKER_IMAGE}:latest .
                '''
            }
        }

        // Stage 3: Test Docker image
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

        // Stage 4: Push image to Docker Hub
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

        // Stage 5: Deploy application to AWS EC2
        stage('Deploy to AWS EC2') {
            steps {
                sshagent(['app-ec2-ssh-key']) {
                    sh '''
                        set -e

                        ssh -o StrictHostKeyChecking=no \
                            ubuntu@${APP_SERVER_IP} \
                            'sudo docker pull akashpatel24/newimage:latest && (sudo docker rm -f aws-cicd-app || true) && sudo docker run -d --restart unless-stopped --name aws-cicd-app -p 80:80 akashpatel24/newimage:latest'
                    '''
                }
            }
        }
    }

    // Post-build actions
    post {
        success {
            echo 'SUCCESS: Complete AWS CI/CD Pipeline!'
            echo 'Application deployed successfully to AWS EC2.'
        }

        failure {
            echo 'FAILED: Check Jenkins Console Output.'
        }
    }
}