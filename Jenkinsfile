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
        SONAR_QUBE_HOME = tool 'SonarQube Scanner'
    }
    /*
    ./gradlew sonar \
        -Dsonar.projectKey=app \
        -Dsonar.projectName='app' \
        -Dsonar.host.url=http://localhost:9000 \
        -Dsonar.token=sqp_25e474c7be64336c3eb42a18348b9162cf01146d
    */

    stages {
        stage('Sonar Analysis') {
            steps { // sqp_25e474c7be64336c3eb42a18348b9162cf01146d
                withSonarQubeEnv(credentialsId:'app')
                    powershell '''
                        ./gradlew sonar \
                            -Dsonar.projectKey=app \
                            -Dsonar.projectName='app' \
                            -Dsonar.host.url=http://localhost:9000 \
                            -Dsonar.token=sqp_25e474c7be64336c3eb42a18348b9162cf01146d
                    '''
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
                    # List and remove existing containers.
                    docker ps -a 
                    docker stop prometheus
                    docker rm prometheus
                    docker stop grafana
                    docker rm grafana
                    docker build -t ${env:GRAFANA} -f scripts/grafana/Dockerfile .
                    docker build -t ${env:PROMETHEUS} -f scripts/prometheus/Dockerfile .
                    docker run -d --name prometheus \
                        -p 9090:9090 \
                        -v ${PWD}/scripts/prometheus/prometheus.yaml:/etc/prometheus/prometheus.yml \
                        ${env:PROMETHEUS}
                    docker run -d --name grafana \
                        -p 3000:3000 \
                        ${env:GRAFANA} \
                        #-v ${PWD}/dashboards/grafana-prometheus.json:/etc/grafana/provisioning/dashboards/main.yml \
                        #-v ${PWD}/dashboards:/var/lib/grafana/dashboards
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
        success {
            echo "Done. Congratulations! If you ever read this message lol!"
        }
        failure {
            echo "The expected outcome."
        }
    }
}