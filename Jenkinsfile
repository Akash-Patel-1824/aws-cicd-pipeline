pipeline {
    agent any

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
                    -t $DOCKER_IMAGE:$BUILD_NUMBER \
                    -t $DOCKER_IMAGE:latest .
                '''
            }
        }

        stage('Test Docker Image') {
            steps {
                sh '''
                    docker rm -f aws-cicd-test || true
                    docker run -d --name aws-cicd-test \
                    -p 8081:80 $DOCKER_IMAGE:$BUILD_NUMBER

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
                        echo "$DOCKER_PASS" | docker login \
                        -u "$DOCKER_USER" --password-stdin

                        docker push $DOCKER_IMAGE:$BUILD_NUMBER
                        docker push $DOCKER_IMAGE:latest

                        docker logout
                    '''
                }
            }
        }
    }
}
