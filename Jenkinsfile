pipeline {
    agent any

    tools {
        jdk 'jdk21'
        maven 'maven3'
    }

    environment {
        SCANNER_HOME       = tool 'sonar-scanner'
        DOCKERHUB_USERNAME = 'manish26m'
        IMAGE_NAME         = "${DOCKERHUB_USERNAME}/boardgame"
        IMAGE_TAG          = 'latest'
    }

    stages {

        // Stage 1: Pull latest code from GitHub
        stage('Git Checkout') {
            steps {
                checkout scm
            }
        }

        // Stage 2: Compile Java source code
        stage('Compile') {
            steps {
                bat 'mvn compile'
            }
        }

        // Stage 3: Run unit tests
        stage('Test') {
            steps {
                bat 'mvn test'
            }
        }

        // Stage 4: Scan project files for vulnerabilities using Trivy
        stage('Trivy FS Scan') {
            steps {
                bat 'curl -sfL "https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/html.tpl" -o trivy-html.tpl'
                bat '''
                "C:\\Users\\manis\\AppData\\Local\\Microsoft\\WinGet\\Packages\\AquaSecurity.Trivy_Microsoft.Winget.Source_8wekyb3d8bbwe\\trivy.exe" fs ^
                --format template ^
                --template "@trivy-html.tpl" ^
                --output trivy-fs-report.html .
                '''
            }
        }

        // Stage 5: Static code analysis with SonarQube
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    bat """
                        "C:\\ProgramData\\Jenkins\\.jenkins\\tools\\hudson.plugins.sonar.SonarRunnerInstallation\\sonar-scanner\\bin\\sonar-scanner.bat" ^
                        -Dsonar.projectName=BoardUniverse ^
                        -Dsonar.projectKey=BoardUniverse ^
                        -Dsonar.java.binaries=target/classes ^
                        -Dsonar.sources=src/main ^
                        -Dsonar.tests=src/test ^
                        -Dsonar.junit.reportPaths=target/surefire-reports ^
                        -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
                    """
                }
            }
        }

        // Stage 6: Wait for SonarQube Quality Gate result
        stage('Quality Gate') {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate abortPipeline: false
                }
            }
        }

        // Stage 7: Package application into a JAR
        stage('Build Package') {
            steps {
                bat 'mvn package -DskipTests=true'
            }
        }

        // Stage 8: Upload JAR artifact to Nexus repository
        stage('Publish to Nexus') {
            steps {
                nexusArtifactUploader(
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    nexusUrl: 'localhost:8081',
                    groupId: 'com.javaproject',
                    version: '0.0.5',
                    repository: 'boardgame-releases',
                    credentialsId: 'nexus-cred',
                    artifacts: [[
                        artifactId: 'database_service_project',
                        classifier: '',
                        file: 'target/database_service_project-0.0.5.jar',
                        type: 'jar'
                    ]]
                )
            }
        }

        // Stage 9: Build Docker image
        stage('Docker Build') {
            steps {
                withDockerRegistry(credentialsId: 'docker-cred', url: 'https://index.docker.io/v1/') {
                    bat "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                }
            }
        }

        // Stage 10: Scan Docker image for vulnerabilities using Trivy
        stage('Trivy Image Scan') {
            steps {
                bat '''
                "C:\\Users\\manis\\AppData\\Local\\Microsoft\\WinGet\\Packages\\AquaSecurity.Trivy_Microsoft.Winget.Source_8wekyb3d8bbwe\\trivy.exe" image ^
                --format template ^
                --template "@trivy-html.tpl" ^
                --output trivy-image-report.html ^
                %IMAGE_NAME%:%IMAGE_TAG%
                '''
            }
        }

        // Stage 11: Push Docker image to DockerHub
        stage('Docker Push') {
            steps {
                withDockerRegistry(credentialsId: 'docker-cred', url: 'https://index.docker.io/v1/') {
                    bat "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }

        // Stage 12: Deploy container locally on port 8085
        stage('Deploy') {
            steps {
                bat 'docker stop boardgame || ver > nul'
                bat 'docker rm boardgame || ver > nul'
                bat "docker run -d -p 8085:8080 --name boardgame ${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }
    }

    post {
        always {
            emailext(
                subject: "[${currentBuild.result ?: 'SUCCESS'}] BoardUniverse Pipeline - Build #${env.BUILD_NUMBER}",
                body: """
                    <h2>&#x1F3AE; BoardUniverse CI/CD Pipeline Report</h2>
                    <table border='1' cellpadding='8' cellspacing='0'>
                        <tr><td><b>Pipeline</b></td><td>${env.JOB_NAME}</td></tr>
                        <tr><td><b>Build Number</b></td><td>#${env.BUILD_NUMBER}</td></tr>
                        <tr><td><b>Status</b></td><td><b>${currentBuild.result ?: 'SUCCESS'}</b></td></tr>
                        <tr><td><b>Duration</b></td><td>${currentBuild.durationString}</td></tr>
                        <tr><td><b>Build URL</b></td><td><a href="${env.BUILD_URL}">${env.BUILD_URL}</a></td></tr>
                    </table>
                    <br>
                    <p>Trivy security scan reports are attached. Please review any vulnerabilities found.</p>
                    <p>-- Automated notification from Jenkins CI/CD</p>
                """,
                to: 'manish.mishra2605@gmail.com',
                mimeType: 'text/html',
                attachmentsPattern: 'trivy-fs-report.html,trivy-image-report.html'
            )
        }
    }
}
