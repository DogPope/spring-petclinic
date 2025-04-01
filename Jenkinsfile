pipeline {
    agent any
    environment{
        CLOUDSDK_CORE_PROJECT = "spring-petclinic-455216" // Gets called Automatically by Jenkins?
    }
    stages {
        stage('Gcloud Activation') {
            steps {
                withCredentials([file(credentialsId: 'gcloudcredentials', variable: 'gcloudcredentials')]) {
                    bat '''
                        echo "Running gcloud version..."
                        gcloud version || echo "Failed to execute 'gcloud version'"
                        
                        echo "Authenticating with gcloud credentials..."
                        gcloud auth activate-service-account --key-file="C:\\Users\\Daniel Jameson\\Downloads\\spring-petclinic-455216-56d70a4e1ff6.json"
                        
                        echo "Listing compute zones..."
                        gcloud compute zones list || echo "Failed to list compute zones"
                    '''
                }
            }
        }
        // stage('Checkout') {
        //     steps {
        //         git branch: 'main', url: 'https://github.com/spring-projects/spring-petclinic.git'
        //     }
        // }
        stage('Clean') {
            steps {
                bat './gradlew clean'
            }
        }
        // stage('Scan') {
        //     steps {
        //         withSonarQubeEnv('SonarQube') {
        //             bat '''
        //             docker run --rm -v "%CD%":/app -w /app maven:3.8.7 mvn sonar:sonar \
        //                 -Dsonar.projectKey=spring-petclinic \
        //                 -Dsonar.host.url=http://192.168.130.132:9000 \
        //                 -Dsonar.login=sqa_05c9624bf6a7e7680fdae2793fb56b1cd95c4e55 \
        //                 -Dsonar.java.binaries=target/classes \
        //                 -Dcheckstyle.skip=true
        //             '''
        //         }
        //     }
        // }
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