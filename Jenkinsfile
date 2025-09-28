pipeline {
    agent any

    environment {
        FRONTEND_IMAGE = '688372068524.dkr.ecr.ap-south-1.amazonaws.com/capstoneproject/frontend-image'
        BACKEND_IMAGE  = '688372068524.dkr.ecr.ap-south-1.amazonaws.com/capstoneproject/backend-image'
        AWS_REGION     = 'ap-south-1'
        REPO_URL       = 'https://github.com/sachinashokyadav/capstone-project.git'
        BRANCH         = 'main'
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo 'Cloning GitHub repository...'
                git branch: "${BRANCH}", url: "${REPO_URL}"
            }
        }

        stage('Dependency Check (Optional)') {
            steps {
                script {
                    echo 'Running dependency check...'
                    sh '''
                    docker run --rm \
                        -v $(pwd):/src \
                        owasp/dependency-check \
                        --project "capstone-project" \
                        --scan /src/backend /src/frontend \
                        --format HTML \
                        --out /src/dependency-check-report
                    '''.stripIndent()
                }
            }
        }

        stage('Sensitive File Scan (Optional)') {
            steps {
                script {
                    echo 'Scanning for sensitive information using truffleHog...'
                    sh '''
                    docker run --rm -v $(pwd):/pwd -w /pwd trufflesecurity/trufflehog:latest filesystem . || true
                    '''.stripIndent()
                }
            }
        }

        stage('Build Frontend Docker Image') {
            steps {
                script {
                    echo 'Building frontend Docker image...'
                    sh "docker build -t ${FRONTEND_IMAGE}:latest ./frontend"
                }
            }
        }

        stage('Build Backend Docker Image') {
            steps {
                script {
                    echo 'Building backend Docker image...'
                    sh "docker build -t ${BACKEND_IMAGE}:latest ./backend"
                }
            }
        }

        stage('Trivy Image Scan') {
            steps {
                script {
                    echo 'Running Trivy scans on Docker images...'
                    sh '''
                    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image ${FRONTEND_IMAGE}:latest || true
                    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image ${BACKEND_IMAGE}:latest || true
                    '''.stripIndent()
                }
            }
        }

        stage('Push Images to AWS ECR') {
            steps {
                script {
                    echo 'Logging in to AWS ECR...'
                    sh '''
                    aws ecr get-login-password --region ${AWS_REGION} | \
                        docker login --username AWS --password-stdin 688372068524.dkr.ecr.ap-south-1.amazonaws.com
                    '''

                    echo 'Pushing frontend image...'
                    sh "docker push ${FRONTEND_IMAGE}:latest"

                    echo 'Pushing backend image...'
                    sh "docker push ${BACKEND_IMAGE}:latest"
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up Docker resources...'
            sh '''
            docker system prune -af || true
            '''
        }
    }
}
