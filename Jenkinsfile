pipeline {
    agent any
    
    // Reference your Terraform installation name from Global Tool Configuration
    tools {
        terraform 'terraform' 
    }

    stages {
        stage('Checkout') {
            steps {
                // Pull code from your Git repository
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                // Initialize the backend and providers
                sh 'terraform init'
            }
        }

        stage('Terraform Validate & Lint') {
            steps {
                // Check syntax and formatting
                sh 'terraform validate'
                sh 'terraform fmt -check'
            }
        }

        stage('Terraform Plan') {
            steps {
                // Generate and save an execution plan
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Approval') {
            // Optional: Pause for manual verification before applying changes
            steps {
                input message: 'Do you want to apply these changes?'
            }
        }

        stage('Terraform Apply') {
            steps {
                // Apply the plan without interactive prompts
                sh 'terraform apply -auto-approve tfplan'
            }
        }
    }
}
