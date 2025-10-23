# dj-compose-ansible-cicd

project-root/
├── ansible/
│   ├── inventory/
│   │   ├── dev.ini
│   │   └── prod.ini
│   ├── group_vars/
│   │   ├── dev.yml
│   │   └── prod.yml
│   ├── playbooks/
│   │   └── deploy.yml
│   ├── roles/
│   │   ├── docker_setup/
│   │   │   ├── tasks/
│   │   │   └── handlers/
│   │   └── app_deploy/
│   │       ├── tasks/
│   │       ├── handlers/
│   │       └── templates/
│   └── ansible.cfg
├── docker-compose.yml
├── Dockerfile
└── Jenkinsfile