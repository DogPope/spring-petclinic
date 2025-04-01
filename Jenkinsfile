pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/spring-projects/spring-petclinic.git'
            }
        }
        stage('Clean') {
            steps {
                bat './gradlew clean'
            }
        }
        stage('Scan') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    bat '''
                    docker run --rm -v "%CD%":/app -w /app openjdk:11 ./gradlew sonarqube \
                        -Dsonar.projectKey=spring-petclinic \
                        -Dsonar.host.url=http://192.168.130.132:9000 \
                        -Dsonar.login=sqa_05c9624bf6a7e7680fdae2793fb56b1cd95c4e55 \
                        -Dsonar.java.binaries=build/libs \
                        -Dcheckstyle.skip=true
                    '''
                }
            }
        }
        stage('Build') {
            steps {
                bat './gradlew build'
            }
        }
        stage('Test') {
            steps {
                bat './gradlew test'
                // Deployment Goes here.
            }
        }
    }
}