pipeline {
    agent any

    environment {
        AWS_REGION        = 'us-east-1'
        AWS_ACCOUNT_ID    = credentials('aws-account-id')
        ECR_REGISTRY      = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        EKS_CLUSTER_NAME  = 'hybrid-app-cluster'
        ARTIFACTORY_URL   = credentials('artifactory-url')
        ARTIFACTORY_CREDS = credentials('artifactory-credentials')
        DOCKER_REGISTRY   = 'localhost:5000'  // Local Docker registry for on-prem
        BUILD_NUMBER_TAG  = "${BUILD_NUMBER}"
    }

    tools {
        maven 'Maven-3.9'
        jdk 'JDK-21'
        nodejs 'NodeJS-20'
    }

    stages {

        // ========================
        // STAGE 1: BUILD ALL APPS
        // ========================

        stage('Build') {
            parallel {
                stage('Build Java App') {
                    steps {
                        dir('apps/java-app') {
                            sh 'mvn clean package -DskipTests -B'
                        }
                    }
                }
                stage('Build Angular App') {
                    steps {
                        dir('apps/angular-app') {
                            sh 'npm install'
                            sh 'npm run build'
                        }
                    }
                }
                stage('Build Python App') {
                    steps {
                        dir('apps/python-app') {
                            sh 'pip install -r requirements.txt'
                        }
                    }
                }
            }
        }

        // ========================
        // STAGE 2: TEST ALL APPS
        // ========================

        stage('Test') {
            parallel {
                stage('Test Java App') {
                    steps {
                        dir('apps/java-app') {
                            sh 'mvn test -B'
                        }
                    }
                    post {
                        always {
                            junit allowEmptyResults: true, testResults: 'apps/java-app/target/surefire-reports/*.xml'
                        }
                    }
                }
                stage('Test Python App') {
                    steps {
                        dir('apps/python-app') {
                            sh 'python -m pytest tests/ --junitxml=test-results.xml || true'
                        }
                    }
                }
            }
        }

        // ===================================
        // STAGE 3: PUBLISH TO ARTIFACTORY
        // ===================================

        stage('Publish to Artifactory') {
            parallel {
                stage('Publish Java Artifact') {
                    steps {
                        dir('apps/java-app') {
                            sh """
                                curl -u ${ARTIFACTORY_CREDS} -T target/*.jar \
                                "${ARTIFACTORY_URL}/libs-release-local/com/kaeliq/hybrid-java-app/${BUILD_NUMBER_TAG}/hybrid-java-app-${BUILD_NUMBER_TAG}.jar"
                            """
                        }
                    }
                }
                stage('Publish Angular Artifact') {
                    steps {
                        dir('apps/angular-app') {
                            sh "tar -czf angular-app-${BUILD_NUMBER_TAG}.tar.gz -C dist/hybrid-angular-app/browser ."
                            sh """
                                curl -u ${ARTIFACTORY_CREDS} -T angular-app-${BUILD_NUMBER_TAG}.tar.gz \
                                "${ARTIFACTORY_URL}/libs-release-local/com/kaeliq/hybrid-angular-app/${BUILD_NUMBER_TAG}/hybrid-angular-app-${BUILD_NUMBER_TAG}.tar.gz"
                            """
                        }
                    }
                }
                stage('Publish Python Artifact') {
                    steps {
                        dir('apps/python-app') {
                            sh "tar -czf python-app-${BUILD_NUMBER_TAG}.tar.gz *.py requirements.txt"
                            sh """
                                curl -u ${ARTIFACTORY_CREDS} -T python-app-${BUILD_NUMBER_TAG}.tar.gz \
                                "${ARTIFACTORY_URL}/libs-release-local/com/kaeliq/hybrid-python-app/${BUILD_NUMBER_TAG}/hybrid-python-app-${BUILD_NUMBER_TAG}.tar.gz"
                            """
                        }
                    }
                }
            }
        }

        // ===================================
        // STAGE 4: DOCKER BUILD & PUSH LOCAL
        // ===================================

        stage('Docker Build & Push (On-Prem)') {
            parallel {
                stage('Docker: Java') {
                    steps {
                        dir('apps/java-app') {
                            sh "docker build -t ${DOCKER_REGISTRY}/hybrid-java-app:${BUILD_NUMBER_TAG} ."
                            sh "docker build -t ${DOCKER_REGISTRY}/hybrid-java-app:latest ."
                            sh "docker push ${DOCKER_REGISTRY}/hybrid-java-app:${BUILD_NUMBER_TAG}"
                            sh "docker push ${DOCKER_REGISTRY}/hybrid-java-app:latest"
                        }
                    }
                }
                stage('Docker: Angular') {
                    steps {
                        dir('apps/angular-app') {
                            sh "docker build -t ${DOCKER_REGISTRY}/hybrid-angular-app:${BUILD_NUMBER_TAG} ."
                            sh "docker build -t ${DOCKER_REGISTRY}/hybrid-angular-app:latest ."
                            sh "docker push ${DOCKER_REGISTRY}/hybrid-angular-app:${BUILD_NUMBER_TAG}"
                            sh "docker push ${DOCKER_REGISTRY}/hybrid-angular-app:latest"
                        }
                    }
                }
                stage('Docker: Python') {
                    steps {
                        dir('apps/python-app') {
                            sh "docker build -t ${DOCKER_REGISTRY}/hybrid-python-app:${BUILD_NUMBER_TAG} ."
                            sh "docker build -t ${DOCKER_REGISTRY}/hybrid-python-app:latest ."
                            sh "docker push ${DOCKER_REGISTRY}/hybrid-python-app:${BUILD_NUMBER_TAG}"
                            sh "docker push ${DOCKER_REGISTRY}/hybrid-python-app:latest"
                        }
                    }
                }
            }
        }

        // ===================================
        // STAGE 5: DOCKER PUSH TO AWS ECR
        // ===================================

        stage('Push to AWS ECR') {
            steps {
                withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}"

                    // Tag & push Java
                    sh "docker tag ${DOCKER_REGISTRY}/hybrid-java-app:${BUILD_NUMBER_TAG} ${ECR_REGISTRY}/hybrid-java-app:${BUILD_NUMBER_TAG}"
                    sh "docker tag ${DOCKER_REGISTRY}/hybrid-java-app:latest ${ECR_REGISTRY}/hybrid-java-app:latest"
                    sh "docker push ${ECR_REGISTRY}/hybrid-java-app:${BUILD_NUMBER_TAG}"
                    sh "docker push ${ECR_REGISTRY}/hybrid-java-app:latest"

                    // Tag & push Angular
                    sh "docker tag ${DOCKER_REGISTRY}/hybrid-angular-app:${BUILD_NUMBER_TAG} ${ECR_REGISTRY}/hybrid-angular-app:${BUILD_NUMBER_TAG}"
                    sh "docker tag ${DOCKER_REGISTRY}/hybrid-angular-app:latest ${ECR_REGISTRY}/hybrid-angular-app:latest"
                    sh "docker push ${ECR_REGISTRY}/hybrid-angular-app:${BUILD_NUMBER_TAG}"
                    sh "docker push ${ECR_REGISTRY}/hybrid-angular-app:latest"

                    // Tag & push Python
                    sh "docker tag ${DOCKER_REGISTRY}/hybrid-python-app:${BUILD_NUMBER_TAG} ${ECR_REGISTRY}/hybrid-python-app:${BUILD_NUMBER_TAG}"
                    sh "docker tag ${DOCKER_REGISTRY}/hybrid-python-app:latest ${ECR_REGISTRY}/hybrid-python-app:latest"
                    sh "docker push ${ECR_REGISTRY}/hybrid-python-app:${BUILD_NUMBER_TAG}"
                    sh "docker push ${ECR_REGISTRY}/hybrid-python-app:latest"
                }
            }
        }

        // ===================================
        // STAGE 6: DEPLOY TO LOCAL DOCKER
        // ===================================

        stage('Deploy to Local Docker') {
            steps {
                dir('docker') {
                    sh 'docker-compose down || true'
                    sh 'docker-compose up -d'
                    sh 'docker-compose ps'
                }
            }
        }

        // ===================================
        // STAGE 7: DEPLOY TO AWS EKS
        // ===================================

        stage('Deploy to EKS') {
            steps {
                withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                    sh "aws eks update-kubeconfig --name ${EKS_CLUSTER_NAME} --region ${AWS_REGION}"

                    // Create namespace if not exists
                    sh 'kubectl apply -f k8s/namespace.yml'

                    // Replace placeholder with actual ECR registry
                    sh "sed -i 's|DOCKER_REGISTRY|${ECR_REGISTRY}|g' k8s/java/deployment.yml"
                    sh "sed -i 's|DOCKER_REGISTRY|${ECR_REGISTRY}|g' k8s/python/deployment.yml"
                    sh "sed -i 's|DOCKER_REGISTRY|${ECR_REGISTRY}|g' k8s/angular/deployment.yml"

                    // Deploy all services
                    sh 'kubectl apply -f k8s/java/deployment.yml'
                    sh 'kubectl apply -f k8s/python/deployment.yml'
                    sh 'kubectl apply -f k8s/angular/deployment.yml'

                    // Wait for rollout
                    sh 'kubectl rollout status deployment/java-app -n hybrid-app --timeout=120s'
                    sh 'kubectl rollout status deployment/python-app -n hybrid-app --timeout=120s'
                    sh 'kubectl rollout status deployment/angular-app -n hybrid-app --timeout=120s'

                    // Show status
                    sh 'kubectl get pods -n hybrid-app'
                    sh 'kubectl get svc -n hybrid-app'
                }
            }
        }
    }

    post {
        success {
            echo '===================================='
            echo 'Pipeline completed successfully!'
            echo 'Local Docker: http://localhost:4200'
            echo 'EKS: Check kubectl get svc -n hybrid-app for external URL'
            echo '===================================='
        }
        failure {
            echo 'Pipeline failed! Check logs above.'
        }
        always {
            cleanWs()
        }
    }
}
