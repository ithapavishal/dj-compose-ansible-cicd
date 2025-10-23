pipeline {
    agent any

    environment {
        COMPOSE_PROJECT_NAME = "employee"
        ANSIBLE_CONFIG = "${WORKSPACE}/ansible.cfg"
        DOCKERHUB_IMAGE = "thapavishal/employee"
    }

    stages {
        stage('Checkout from GitHub') {
            steps {
                checkout scm
            }
        }

        stage('Setup Environment') {
            steps {
                sh '''
                echo "[defaults]" > ansible.cfg
                echo "host_key_checking = False" >> ansible.cfg
                echo "remote_user = vagrant" >> ansible.cfg
                echo "private_key_file = /home/vagrant/ansible-keys" >> ansible.cfg
                
                '''
            }
        }

        stage('Build & Start with Docker Compose') {
            steps {
                sh '''
                echo "Building and starting Docker Compose services..."
                docker compose down --remove-orphans  # Clean up previous deployment
                docker compose build                  # Build fresh images
                docker compose up -d                  # Start new containers in detached mode

                echo "Waiting for services to be healthy..."
                sleep 30
                
                echo "Checking running containers..."
                docker compose ps
                
                echo "Checking Django service logs..."
                docker compose logs web_services
                
                echo "Checking PostgreSQL service logs..."
                docker compose logs postgres_db
                '''
            }
        }

        // stage('Build & Start with Docker Compose') {
        //     steps {
        //         script {
        //             withDockerRegistry([credentialsId: 'dockerhub-credentials', url: '']) {
        //                 sh '''
        //                 echo "Building and starting Docker Compose services..."
                        
                        
        //                 echo "Waiting for services to be healthy..."
        //                 sleep 30
                        
        //              docker-compose down || true
        //                 docker-compose build --no-cache
        //                 docker-compose up -d   echo "Checking running containers..."
        //                 docker-compose ps
                        
        //                 echo "Checking Django service logs..."
        //                 docker-compose logs web_services
                        
        //                 echo "Checking PostgreSQL service logs..."
        //                 docker-compose logs postgres_db
        //                 '''
        //             }
        //         }
        //     }
        // }


        stage('Push to DockerHub') {
            steps {
                script {
                    withDockerRegistry([credentialsId: 'dockerhub-credentials', url: '']) {
                        // push the web_services image that was built
                        sh '''
                        echo "Tagging and pushing image to DockerHub..."
                        docker tag ${COMPOSE_PROJECT_NAME}_web_services:latest $DOCKERHUB_IMAGE:${BUILD_NUMBER}
                        docker tag ${COMPOSE_PROJECT_NAME}_web_services:latest $DOCKERHUB_IMAGE:latest
                        docker push $DOCKERHUB_IMAGE:${BUILD_NUMBER}
                        docker push $DOCKERHUB_IMAGE:latest
                        '''
                    }
                }
            }
        }

        // stage('Setup Ansible Dependencies') {
        //     steps {
        //         sh '''
        //         echo "Installing Ansible and Docker dependencies..."
        //         pip3 install ansible docker
                
        //         echo "Installing Ansible Docker collection..."
        //         ansible-galaxy collection install community.docker
        //         '''
        //     }
        // }

        stage('Deploy to Development') {
            steps {
                sshagent(credentials: ['vagrant-ssh-key']) {
                    sh '''
                    ansible-playbook -i ansible/inventory/dev.ini ansible/playbooks/deploy.yml \
                    --extra-vars "env=dev image_tag=$DOCKERHUB_IMAGE:$BUILD_NUMBER"
                    '''
                }
            }
        }

        stage('Deploy to Production') {
            steps {
                timeout(time: 1, unit: 'DAYS') {
                    input message: 'Approve production deployment?'
                }
                sshagent(credentials: ['vagrant-ssh-key']) {
                    sh '''
                    ansible-playbook -i ansible/inventory/prod.ini ansible/playbooks/deploy.yml \
                    --extra-vars "env=prod image_tag=$DOCKERHUB_IMAGE:$BUILD_NUMBER"
                    '''
                }
            }
        }
    }

    post {
        always {
            echo "Build finished. Check status at ${BUILD_URL}"
            
            sh '''
            echo "Cleaning up Docker resources..."
            docker compose down || true
            docker system prune -f || true
            '''
        }
        success {
            echo "Pipeline executed successfully!"
        }
        failure {
            echo "Pipeline failed! Check logs for details."
        }
    }
}