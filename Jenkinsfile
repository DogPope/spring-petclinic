pipeline {
    agent any
    environment {
        PROJECT_ID = "spring-petclinic-455216"
        ARTIFACT_REGISTRY = "europe-west2-docker.pkg.dev"
        REPOSITORY = "petclinic"
        IMAGE_NAME = "petclinic"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        FULL_IMAGE_PATH = "${ARTIFACT_REGISTRY}/${PROJECT_ID}/${REPOSITORY}/${IMAGE_NAME}:${IMAGE_TAG}"
        GKE_CLUSTER = "petclinic-cluster"
        GKE_ZONE = "europe-west2"
        DEPLOYMENT_NAME = "petclinic-deployment"
        GRAFANA = "grafana:latest"
        PROMETHEUS = "prometheus:latest"
        SONAR_QUBE_HOME = tool 'SonarQube'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', credentialsId: 'credential-id', url: 'https://github.com/DogPope/spring-petclinic.git'
            }
        }
        stage('Gradle Build') {
            steps {
                bat './gradlew clean build'
            }
        }
        stage('Sonar Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    bat './gradlew sonar'
                }
            }
        }
        stage('Gcloud Authentication') {
            steps {
                withCredentials([file(credentialsId: 'gcloud-creds', variable: 'gcloud_creds')]) {
                    powershell '''
                        gcloud auth activate-service-account --key-file="$env:gcloud_creds"
			            gcloud auth configure-docker ${env:ARTIFACT_REGISTRY}
                    '''
                }
            }
        }
        stage('Build and Run Monitoring Stack') {
            steps {
                powershell '''
                    docker ps -a 
                    docker build -t ${env:GRAFANA} -f scripts/grafana/Dockerfile .
                    docker build -t ${env:PROMETHEUS} -f scripts/prometheus/Dockerfile .
                    docker run -d --name prometheus \
                        -p 9090:9090 \
                        -v ${PWD}/scripts/prometheus/prometheus.yaml:/etc/prometheus/prometheus.yml \
                        ${env:PROMETHEUS}
                    docker run -d --name grafana \
                        -p 3000:3000 \
                        ${env:GRAFANA} \
                    Start-Sleep -Seconds 10
                    docker ps --filter "name=grafana" --filter "name=prometheus"
                '''
            }
        }
        stage('Build Container Image') {
            steps {
                powershell '''
                    docker build -t ${env:FULL_IMAGE_PATH} .
                '''
            }
        }
        stage('Deploy to Google Kubernetes Engine') {
            steps {
                    withCredentials([file(credentialsId: 'gcloud-creds', variable: 'gcloud_creds')]) {
                        powershell '''
                            gcloud container clusters get-credentials ${env:GKE_CLUSTER} --zone ${env:GKE_ZONE} --project ${env:PROJECT_ID}
                            kubectl create deployment ${env:GKE_CLUSTER} --image=${GKE_ZONE}-docker.pkg.dev/${env:PROJECT_ID}/petclinic/petclinic:v1
                            kubectl scale deployment ${env:GKE_CLUSTER} --replicas=1
                        '''
                    }
                }
        }
    }
    post {
        always {
            emailext (
                subject: "Jenkins Build ${currentBuild.currentResult}: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                    <p>Build Status: ${currentBuild.currentResult}</p>
                    <p>Job: ${env.JOB_NAME}</p>
                    <p>Build Number: ${env.BUILD_NUMBER}</p>
                    <p>URL: <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                """,
                to: "danieljffs@gmail.com",
                mimeType: 'text/html'
            )
        }
        success {
            echo " Build successful!"
        }
        failure {
            echo "Build failed!"
        }
    }
}