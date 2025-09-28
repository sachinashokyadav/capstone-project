pipeline {
    agent any

    environment {
        FRONTEND_IMAGE_NAME = 'capstoneproject/frontend-image'
        BACKEND_IMAGE_NAME = 'capstoneproject/backend-image'
        DOCKER_REGISTRY = '688372068524.dkr.ecr.ap-south-1.amazonaws.com'
        ECR_REPO = 'capstoneproject'
        FRONTEND_PATH = './frontend'
        BACKEND_PATH = './backend'
        REPO_URL = 'https://github.com/sachinashokyadav/capstone-project.git'
        BRANCH = 'main' // Specify the branch you want to deploy
        AWS_REGION = 'ap-south-1' // Specify your AWS region
    }

    stages {
        stage('Checkout Code') {
            steps {
                script {
                    echo 'Cloning GitHub repository...'
                    git branch: "${BRANCH}", url: "${REPO_URL}"
                }
            }
        }

        stage('Dependency Check') {
            steps {
                script {
                    echo 'Running dependency check...'
                    // Use OWASP Dependency-Check, Snyk, or other dependency check tools
                    sh 'dependency-check --scan ${BACKEND_PATH} --scan ${FRONTEND_PATH}'
                }
            }
        }

        stage('File Scan for Sensitive Data') {
            steps {
                script {
                    echo 'Scanning files for sensitive data...'
                    // Use a tool like TruffleHog or GitLeaks to scan files for sensitive data
                    sh 'trufflehog --regex --entropy=True ./'
                }
            }
        }

        stage('Build Frontend Docker Image') {
            steps {
                script {
                    echo 'Building frontend Docker image...'
                    // Build Docker image for the frontend
                    sh 'docker build -t ${DOCKER_REGISTRY}/${ECR_REPO}/${FRONTEND_IMAGE_NAME}:latest ${FRONTEND_PATH}'
                }
            }
        }

        stage('Build Backend Docker Image') {
            steps {
                script {
                    echo 'Building backend Docker image...'
                    // Build Docker image for the backend
                    sh 'docker build -t ${DOCKER_REGISTRY}/${ECR_REPO}/${BACKEND_IMAGE_NAME}:latest ${BACKEND_PATH}'
                }
            }
        }

        stage('Trivy Image Scan') {
            steps {
                script {
                    echo 'Scanning frontend Docker image for vulnerabilities with Trivy...'
                    // Scan the frontend Docker image with Trivy
                    sh 'trivy image ${DOCKER_REGISTRY}/${ECR_REPO}/${FRONTEND_IMAGE_NAME}:latest'

                    echo 'Scanning backend Docker image for vulnerabilities with Trivy...'
                    // Scan the backend Docker image with Trivy
                    sh 'trivy image ${DOCKER_REGISTRY}/${ECR_REPO}/${BACKEND_IMAGE_NAME}:latest'
                }
            }
        }

        stage('Push Frontend Docker Image to AWS ECR') {
            steps {
                script {
                    echo 'Logging into AWS ECR...'
                    // Login to AWS ECR
                    sh '''
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${DOCKER_REGISTRY}
                    '''

                    echo 'Pushing frontend Docker image to AWS ECR...'
                    // Push the frontend Docker image to AWS ECR
                    sh 'docker push ${DOCKER_REGISTRY}/${ECR_REPO}/${FRONTEND_IMAGE_NAME}:latest'
                }
            }
        }

        stage('Push Backend Docker Image to AWS ECR') {
            steps {
                script {
                    echo 'Pushing backend Docker image to AWS ECR...'
                    // Push the backend Docker image to AWS ECR
                    sh 'docker push ${DOCKER_REGISTRY}/${ECR_REPO}/${BACKEND_IMAGE_NAME}:latest'
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up Docker images...'
            // Remove local Docker images to clean up
            sh 'docker system prune -af'
        }
    }
}
