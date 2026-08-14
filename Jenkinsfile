pipeline {
    agent any

    environment {
        DOCKERHUB_NAMESPACE = 'thatipraveen23'
        IMAGE_TAG           = "${env.BUILD_NUMBER}"
        GIT_REPO            = 'github.com/praveenthati23/k8s-springboot-react-lab.git'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build and Push Backend Image') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-creds') {
                        def backendImage = docker.build(
                            "${DOCKERHUB_NAMESPACE}/k8s-lab-backend:${IMAGE_TAG}",
                            "./backend"
                        )
                        backendImage.push()
                        backendImage.push('latest')
                    }
                }
            }
        }

        stage('Build and Push Frontend Image') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-creds') {
                        def frontendImage = docker.build(
                            "${DOCKERHUB_NAMESPACE}/k8s-lab-frontend:${IMAGE_TAG}",
                            "./frontend"
                        )
                        frontendImage.push()
                        frontendImage.push('latest')
                    }
                }
            }
        }

        // -----------------------------------------------------------------
        // This is the core GitOps mechanic. Instead of Jenkins calling
        // kubectl to push changes into the cluster (like our GitHub
        // Actions version did), Jenkins only edits the YAML files in the
        // repo itself - changing the image tag - and commits/pushes that
        // change back to git. ArgoCD, running inside the cluster, is
        // separately watching this same repo and will detect the commit
        // and sync automatically (for dev) or wait for manual sync (prod).
        // Jenkins never needs cluster credentials at all.
        // -----------------------------------------------------------------
        stage('Update Dev Manifests') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'github-creds', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_TOKEN')]) {
                    sh '''
                        sed -i "s|image: ${DOCKERHUB_NAMESPACE}/k8s-lab-backend:.*|image: ${DOCKERHUB_NAMESPACE}/k8s-lab-backend:${IMAGE_TAG}|" k8s-manifests/dev/backend.yaml
                        sed -i "s|image: ${DOCKERHUB_NAMESPACE}/k8s-lab-frontend:.*|image: ${DOCKERHUB_NAMESPACE}/k8s-lab-frontend:${IMAGE_TAG}|" k8s-manifests/dev/frontend.yaml

                        git config user.email "jenkins@k8s-lab.local"
                        git config user.name "Jenkins CI"
                        git add k8s-manifests/dev/backend.yaml k8s-manifests/dev/frontend.yaml
                        git commit -m "ci: update dev images to build ${IMAGE_TAG}" || echo "No changes to commit"
                        git push https://${GIT_USER}:${GIT_TOKEN}@${GIT_REPO} HEAD:dev
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "Build ${IMAGE_TAG} pushed to Docker Hub and dev manifests updated. ArgoCD will sync dev automatically. Prod requires a manual sync in the ArgoCD UI once you're ready to promote."
        }
        failure {
            echo "Pipeline failed - check the stage logs above."
        }
    }
}
