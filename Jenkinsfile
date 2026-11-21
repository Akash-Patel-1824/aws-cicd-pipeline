pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo 'Source code downloaded successfully'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t aws-cicd-app:${BUILD_NUMBER} .'
            }
        }

        stage('Test Docker Image') {
            steps {
                sh '''
                    docker rm -f aws-cicd-test || true
                    docker run -d --name aws-cicd-test -p 8081:80 aws-cicd-app:${BUILD_NUMBER}
                    sleep 5
                    curl -f http://localhost:8081
                    docker rm -f aws-cicd-test
                '''
            }
        }
    }
}