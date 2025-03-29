pipeline {
    agent docker{}
    stages {
        stage('Clean') {
            steps {
                bat './gradlew clean'
            }
        }
        stage('Test') {
            steps {
                try {
                    bat "./gradlew test"
                }
                catch(err) {
                    testsError = err
                    echo "Test Failure"
                }
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