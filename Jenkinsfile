pipeline {
    agent docker{}
    stages {
        stage('Build') {
            steps {
                bat './gradlew build'
            }
        }
        stage('Test') {
            steps {
                bat './gradlew test'
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