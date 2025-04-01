pipeline {
    agent any
    environment{
        CLOUDSDK_CORE_PROJECT = "spring-petclinic-455216" // Gets called Automatically by Jenkins?
    }
    stages {
        stage('Gcloud Activation') {
            steps {
                withCredentials([file(credentialsId: 'gcloud-creds', variable: 'gcloud_creds')]) {
                    sh '''                        
                        gcloud version
                        gcloud auth activate-service-account --key-file="${gcloud_creds}"
                        gcloud compute zones list
                    '''
                }
            }
        }
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