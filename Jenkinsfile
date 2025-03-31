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
        stage('Build') {
            steps {
                bat './gradlew build'
            }
        }
        stage('Deploy') {
            steps {
                echo "Deploy Still has to be done."
                // Deployment Goes here.
            }
        }
    }
}