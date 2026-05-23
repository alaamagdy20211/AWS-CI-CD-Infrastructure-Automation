pipeline {
    agent any

    tools {
        terraform 'terraform'
    }

    environment {
        AWS_REGION = 'us-east-1'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'AWS-Credentials'
                ]]) {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Validate & Lint') {
            steps {
                sh 'terraform validate'
                sh 'terraform fmt -check'
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'AWS-Credentials'
                ]]) {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Approval') {
            steps {
                input message: 'Do you want to apply these changes?'
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'AWS-Credentials'
                ]]) {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }
    }
}