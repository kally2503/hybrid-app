pipeline {
    agent any

    environment {
        AWS_REGION         = 'us-east-1'
        EKS_CLUSTER_NAME   = 'hybrid-app-cluster'
        ARTIFACTORY_URL    = credentials('artifactory-url')        // e.g. https://mycompany.jfrog.io/artifactory
        ARTIFACTORY_CREDS  = credentials('artifactory-credentials')
        ARTIFACTORY_DOCKER = credentials('artifactory-docker-url') // e.g. mycompany.jfrog.io/docker-local
        DOCKER_LOCAL       = 'localhost:5000'                      // Local Docker registry for on-prem
        BUILD_TAG          = "${BUILD_NUMBER}"
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

        // =============================================
        // STAGE 3: PUBLISH BUILD ARTIFACTS TO ARTIFACTORY
        // =============================================

        stage('Publish Artifacts to Artifactory') {
            parallel {
                stage('Publish Java JAR') {
                    steps {
                        dir('apps/java-app') {
                            sh """
                                curl -u ${ARTIFACTORY_CREDS} -T target/*.jar \
                                "${ARTIFACTORY_URL}/libs-release-local/com/kaeliq/hybrid-java-app/${BUILD_TAG}/hybrid-java-app-${BUILD_TAG}.jar"
                            """
                        }
                    }
                }
                stage('Publish Angular Archive') {
                    steps {
                        dir('apps/angular-app') {
                            sh "tar -czf angular-app-${BUILD_TAG}.tar.gz -C dist/hybrid-angular-app/browser ."
                            sh """
                                curl -u ${ARTIFACTORY_CREDS} -T angular-app-${BUILD_TAG}.tar.gz \
                                "${ARTIFACTORY_URL}/libs-release-local/com/kaeliq/hybrid-angular-app/${BUILD_TAG}/hybrid-angular-app-${BUILD_TAG}.tar.gz"
                            """
                        }
                    }
                }
                stage('Publish Python Archive') {
                    steps {
                        dir('apps/python-app') {
                            sh "tar -czf python-app-${BUILD_TAG}.tar.gz *.py requirements.txt"
                            sh """
                                curl -u ${ARTIFACTORY_CREDS} -T python-app-${BUILD_TAG}.tar.gz \
                                "${ARTIFACTORY_URL}/libs-release-local/com/kaeliq/hybrid-python-app/${BUILD_TAG}/hybrid-python-app-${BUILD_TAG}.tar.gz"
                            """
                        }
                    }
                }
            }
        }

        // =============================================
        // STAGE 4: DOCKER BUILD & PUSH TO ARTIFACTORY
        // =============================================

        stage('Docker Build & Push to Artifactory') {
            steps {
                // Login to Artifactory Docker registry
                sh "docker login -u ${ARTIFACTORY_CREDS_USR} -p ${ARTIFACTORY_CREDS_PSW} ${ARTIFACTORY_DOCKER}"
            }
            parallel {
                stage('Docker: Java → Artifactory') {
                    steps {
                        dir('apps/java-app') {
                            sh "docker build -t ${ARTIFACTORY_DOCKER}/hybrid-java-app:${BUILD_TAG} ."
                            sh "docker tag ${ARTIFACTORY_DOCKER}/hybrid-java-app:${BUILD_TAG} ${ARTIFACTORY_DOCKER}/hybrid-java-app:latest"
                            sh "docker push ${ARTIFACTORY_DOCKER}/hybrid-java-app:${BUILD_TAG}"
                            sh "docker push ${ARTIFACTORY_DOCKER}/hybrid-java-app:latest"
                        }
                    }
                }
                stage('Docker: Angular → Artifactory') {
                    steps {
                        dir('apps/angular-app') {
                            sh "docker build -t ${ARTIFACTORY_DOCKER}/hybrid-angular-app:${BUILD_TAG} ."
                            sh "docker tag ${ARTIFACTORY_DOCKER}/hybrid-angular-app:${BUILD_TAG} ${ARTIFACTORY_DOCKER}/hybrid-angular-app:latest"
                            sh "docker push ${ARTIFACTORY_DOCKER}/hybrid-angular-app:${BUILD_TAG}"
                            sh "docker push ${ARTIFACTORY_DOCKER}/hybrid-angular-app:latest"
                        }
                    }
                }
                stage('Docker: Python → Artifactory') {
                    steps {
                        dir('apps/python-app') {
                            sh "docker build -t ${ARTIFACTORY_DOCKER}/hybrid-python-app:${BUILD_TAG} ."
                            sh "docker tag ${ARTIFACTORY_DOCKER}/hybrid-python-app:${BUILD_TAG} ${ARTIFACTORY_DOCKER}/hybrid-python-app:latest"
                            sh "docker push ${ARTIFACTORY_DOCKER}/hybrid-python-app:${BUILD_TAG}"
                            sh "docker push ${ARTIFACTORY_DOCKER}/hybrid-python-app:latest"
                        }
                    }
                }
            }
        }

        // =============================================
        // STAGE 5: PUSH TO LOCAL DOCKER (ON-PREM)
        // =============================================

        stage('Push to Local Docker Registry') {
            parallel {
                stage('Local: Java') {
                    steps {
                        sh "docker tag ${ARTIFACTORY_DOCKER}/hybrid-java-app:${BUILD_TAG} ${DOCKER_LOCAL}/hybrid-java-app:${BUILD_TAG}"
                        sh "docker tag ${ARTIFACTORY_DOCKER}/hybrid-java-app:latest ${DOCKER_LOCAL}/hybrid-java-app:latest"
                        sh "docker push ${DOCKER_LOCAL}/hybrid-java-app:${BUILD_TAG}"
                        sh "docker push ${DOCKER_LOCAL}/hybrid-java-app:latest"
                    }
                }
                stage('Local: Angular') {
                    steps {
                        sh "docker tag ${ARTIFACTORY_DOCKER}/hybrid-angular-app:${BUILD_TAG} ${DOCKER_LOCAL}/hybrid-angular-app:${BUILD_TAG}"
                        sh "docker tag ${ARTIFACTORY_DOCKER}/hybrid-angular-app:latest ${DOCKER_LOCAL}/hybrid-angular-app:latest"
                        sh "docker push ${DOCKER_LOCAL}/hybrid-angular-app:${BUILD_TAG}"
                        sh "docker push ${DOCKER_LOCAL}/hybrid-angular-app:latest"
                    }
                }
                stage('Local: Python') {
                    steps {
                        sh "docker tag ${ARTIFACTORY_DOCKER}/hybrid-python-app:${BUILD_TAG} ${DOCKER_LOCAL}/hybrid-python-app:${BUILD_TAG}"
                        sh "docker tag ${ARTIFACTORY_DOCKER}/hybrid-python-app:latest ${DOCKER_LOCAL}/hybrid-python-app:latest"
                        sh "docker push ${DOCKER_LOCAL}/hybrid-python-app:${BUILD_TAG}"
                        sh "docker push ${DOCKER_LOCAL}/hybrid-python-app:latest"
                    }
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

        // ===================================================
        // STAGE 7: DEPLOY TO AWS EKS (PULL FROM ARTIFACTORY)
        // ===================================================

        stage('Deploy to EKS') {
            steps {
                withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                    sh "aws eks update-kubeconfig --name ${EKS_CLUSTER_NAME} --region ${AWS_REGION}"

                    // Create namespace
                    sh 'kubectl apply -f k8s/namespace.yml'

                    // Create/Update Artifactory Docker registry secret so EKS can pull images
                    sh """
                        kubectl create secret docker-registry artifactory-registry-secret \
                            --docker-server=${ARTIFACTORY_DOCKER} \
                            --docker-username=${ARTIFACTORY_CREDS_USR} \
                            --docker-password=${ARTIFACTORY_CREDS_PSW} \
                            --namespace=hybrid-app \
                            --dry-run=client -o yaml | kubectl apply -f -
                    """

                    // Replace placeholder with Artifactory Docker registry
                    sh "sed -i 's|DOCKER_REGISTRY|${ARTIFACTORY_DOCKER}|g' k8s/java/deployment.yml"
                    sh "sed -i 's|DOCKER_REGISTRY|${ARTIFACTORY_DOCKER}|g' k8s/python/deployment.yml"
                    sh "sed -i 's|DOCKER_REGISTRY|${ARTIFACTORY_DOCKER}|g' k8s/angular/deployment.yml"

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
            echo '============================================='
            echo 'Pipeline completed successfully!'
            echo '============================================='
            echo 'Flow: Build → Artifactory → Local Docker + EKS (pulls from Artifactory)'
            echo 'Local Docker:  http://localhost:4200'
            echo 'EKS: Run kubectl get svc -n hybrid-app for external URL'
            echo '============================================='
        }
        failure {
            echo 'Pipeline failed! Check logs above.'
        }
        always {
            cleanWs()
        }
    }
}
