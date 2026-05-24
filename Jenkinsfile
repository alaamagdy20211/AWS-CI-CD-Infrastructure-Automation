// pipeline {
//     agent any

//     parameters {
//         choice(name: 'ENV', choices: ['dev_variables', 'prod_variables'], description: 'Select environment')
//     }

//     tools {
//         terraform 'terraform'
//     }

//     environment {
//         AWS_REGION = 'us-east-1'
//     }

//     stages {

//         stage('Checkout') {
//             steps {
//                 checkout scm
//             }
//         }

//         stage('Terraform Init') {
//             steps {
//                 withCredentials([[
//                     $class: 'AmazonWebServicesCredentialsBinding',
//                     credentialsId: 'AWS-Credentials'
//                 ]]) {
//                     sh 'terraform init'
//                 }
//             }
//         }

//         stage('Terraform Validate & Lint') {
//             steps {
//                 sh 'terraform validate'
//                 sh 'terraform fmt -recursive'
//             }
//         }

//         stage('Terraform Plan') {
//             steps {
//                 withCredentials([[
//                     $class: 'AmazonWebServicesCredentialsBinding',
//                     credentialsId: 'AWS-Credentials'
//                 ]]) {
//                     sh """
//                     terraform plan -out=tfplan -var-file=${params.ENV}.tfvars
//                     """
//                 }
//             }
//         }

//         stage('Approval') {
//             steps {
//                 input message: "Do you want to apply changes for ${params.ENV}?"
//             }
//         }

//         stage('Terraform Apply') {
//             steps {
//                 withCredentials([[
//                     $class: 'AmazonWebServicesCredentialsBinding',
//                     credentialsId: 'AWS-Credentials'
//                 ]]) {
//                     sh 'terraform destroy -auto-approve -var-file=${params.ENV}.tfvars'
//                 }
//             }
//         }
//     }
// }
pipeline {
    agent any

    parameters {
        choice(
            name: 'ENV',
            choices: ['dev_variables', 'prod_variables'],
            description: 'Select environment'
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
                }
            }
        }

        stage('Terraform Validate & Lint') {
            steps {
                sh 'terraform validate'
                sh 'terraform fmt -recursive'
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
                input message: "Do you want to apply changes for ${params.ENV}?"
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'AWS-Credentials'
                ]]) {

                    // sh """
                    //     terraform apply \
                    //     -auto-approve tfplan
                    // """

                    sh """
                        terraform destroy \
                        -auto-approve \
                        -var-file=${params.ENV}.tfvars
                    """
                }
            }
        }
    }
}