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
    }
    stages {
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
        stage('Build Grafana and Prometheus') {
            steps {
                powershell '''
                    docker build -t ${env:GRAFANA} -f scripts/grafana/Dockerfile .
                    docker build -t ${env:PROMETHEUS} -f scripts/prometheus/Dockerfile .
                    docker run -d -p 3000:3000 ${env:GRAFANA}
                    docker run -d -p 9090:9090 ${env:PROMETHEUS}
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
        success {
            echo "Done. Congratulations! If you ever read this message lol!"
        }
        failure {
            echo "The expected outcome."
        }
    }
}