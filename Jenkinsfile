pipeline {
    agent any

    parameters {

        choice(
            name: 'ENV',
            choices: ['dev_variables', 'prod_variables'],
            description: 'Select environment tfvars file'
        )

        choice(
            name: 'WORKSPACE',
            choices: ['dev', 'production'],
            description: 'Select terraform workspace'
        )
    }

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

                    sh """
                        terraform workspace select ${params.WORKSPACE} || \
                        terraform workspace new ${params.WORKSPACE}
                    """
                }
            }
        }

        stage('Terraform Format') {
            steps {
                sh 'terraform fmt -recursive'
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {

                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'AWS-Credentials'
                ]]) {

                    sh """
                        terraform plan \
                        -out=tfplan \
                        -var-file=${params.ENV}.tfvars
                    """
                }
            }
        }

        stage('Approval') {
            steps {
                input message: "Apply changes to ${params.WORKSPACE}?"
            }
        }

        stage('Terraform Apply') {
            steps {

                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'AWS-Credentials'
                ]]) {

                    sh '''
                        terraform apply \
                        -auto-approve tfplan
                    '''
                }
            }
        }
    }
}