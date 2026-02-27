pipeline {
    agent any
    
    environment {
        // Docker settings
        DOCKER_IMAGE = 'todo-app'
        DOCKER_TAG = "${BUILD_NUMBER}"
        DOCKER_REGISTRY = 'docker.io' // Change to your registry
        
        // SonarCloud settings
        SONAR_TOKEN = credentials('sonarcloud-token')
        SONAR_HOST_URL = 'https://sonarcloud.io'
        SONAR_ORGANIZATION = 'your-org' // Change this
        SONAR_PROJECT_KEY = 'your-project-key' // Change this
        
        // Snyk settings
        SNYK_TOKEN = credentials('snyk-token')
        
        // Git settings
        GIT_BRANCH = "${env.GIT_BRANCH}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo '📦 Checking out code...'
                checkout scm
                sh 'git rev-parse --short HEAD > .git/commit-id'
                script {
                    env.GIT_COMMIT_SHORT = readFile('.git/commit-id').trim()
                }
            }
        }
        
        stage('Code Quality - SonarCloud') {
            steps {
                echo '🔍 Running SonarCloud analysis...'
                script {
                    // Install sonar-scanner if not available
                    sh '''
                        if ! command -v sonar-scanner &> /dev/null; then
                            echo "Installing sonar-scanner..."
                            wget -q https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.8.0.2856-linux.zip
                            unzip -q sonar-scanner-cli-4.8.0.2856-linux.zip
                            export PATH="$PWD/sonar-scanner-4.8.0.2856-linux/bin:$PATH"
                        fi
                        
                        sonar-scanner \\
                            -Dsonar.organization=${SONAR_ORGANIZATION} \\
                            -Dsonar.projectKey=${SONAR_PROJECT_KEY} \\
                            -Dsonar.sources=. \\
                            -Dsonar.host.url=${SONAR_HOST_URL} \\
                            -Dsonar.login=${SONAR_TOKEN} \\
                            -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info
                    '''
                }
            }
        }
        
        stage('Security Scan - Snyk') {
            steps {
                echo '🔒 Running Snyk security scan...'
                script {
                    sh '''
                        # Install Snyk CLI if not available
                        if ! command -v snyk &> /dev/null; then
                            echo "Installing Snyk CLI..."
                            curl -L https://static.snyk.io/cli/latest/snyk-linux -o snyk
                            chmod +x snyk
                            mv snyk /usr/local/bin/ || sudo mv snyk /usr/local/bin/
                        fi
                        
                        # Authenticate Snyk
                        snyk auth ${SNYK_TOKEN}
                        
                        # Test for vulnerabilities
                        snyk test --all-projects || true
                        
                        # Monitor project
                        snyk monitor --all-projects || true
                    '''
                }
            }
        }
        
        stage('Docker Build') {
            steps {
                echo '🐳 Building Docker image...'
                script {
                    sh """
                        docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                        docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest
                    """
                }
            }
        }
        
        stage('Docker Security Scan - Snyk') {
            steps {
                echo '🔐 Scanning Docker image for vulnerabilities...'
                script {
                    sh """
                        snyk container test ${DOCKER_IMAGE}:${DOCKER_TAG} \\
                            --severity-threshold=high \\
                            --file=Dockerfile || true
                        
                        snyk container monitor ${DOCKER_IMAGE}:${DOCKER_TAG} \\
                            --file=Dockerfile || true
                    """
                }
            }
        }
        
        stage('Docker Test') {
            steps {
                echo '🧪 Testing Docker container...'
                script {
                    sh """
                        # Run container
                        docker run -d --name test-container -p 8081:80 ${DOCKER_IMAGE}:${DOCKER_TAG}
                        
                        # Wait for container to be healthy
                        sleep 5
                        
                        # Test health endpoint
                        curl -f http://localhost:8081/health || exit 1
                        
                        # Test main page
                        curl -f http://localhost:8081/ || exit 1
                        
                        # Cleanup
                        docker stop test-container
                        docker rm test-container
                    """
                }
            }
        }
        
        stage('Quality Gate') {
            steps {
                echo '✅ Checking quality gates...'
                script {
                    // Wait for SonarCloud quality gate
                    timeout(time: 5, unit: 'MINUTES') {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            echo "⚠️  Quality Gate failed: ${qg.status}"
                            // Uncomment to fail the build on quality gate failure
                            // error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        } else {
                            echo "✅ Quality Gate passed!"
                        }
                    }
                }
            }
        }
        
        stage('Push to Registry') {
            when {
                branch 'main'
            }
            steps {
                echo '📤 Pushing Docker image to registry...'
                script {
                    // Login and push to Docker registry
                    withCredentials([usernamePassword(credentialsId: 'docker-registry-credentials', 
                                                     usernameVariable: 'DOCKER_USER', 
                                                     passwordVariable: 'DOCKER_PASS')]) {
                        sh """
                            echo ${DOCKER_PASS} | docker login ${DOCKER_REGISTRY} -u ${DOCKER_USER} --password-stdin
                            docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_REGISTRY}/${DOCKER_USER}/${DOCKER_IMAGE}:${DOCKER_TAG}
                            docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_REGISTRY}/${DOCKER_USER}/${DOCKER_IMAGE}:latest
                            docker push ${DOCKER_REGISTRY}/${DOCKER_USER}/${DOCKER_IMAGE}:${DOCKER_TAG}
                            docker push ${DOCKER_REGISTRY}/${DOCKER_USER}/${DOCKER_IMAGE}:latest
                        """
                    }
                }
            }
        }
        
        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                echo '🚀 Deploying application...'
                script {
                    // Deploy using docker-compose or kubernetes
                    sh """
                        docker-compose -f docker-compose.prod.yml down || true
                        docker-compose -f docker-compose.prod.yml up -d
                    """
                }
            }
        }
    }
    
    post {
        always {
            echo '🧹 Cleaning up...'
            sh '''
                # Clean up Docker images
                docker system prune -f || true
            '''
        }
        success {
            echo '✅ Pipeline completed successfully!'
            // Add notifications here (Slack, email, etc.)
        }
        failure {
            echo '❌ Pipeline failed!'
            // Add failure notifications here
        }
    }
}
