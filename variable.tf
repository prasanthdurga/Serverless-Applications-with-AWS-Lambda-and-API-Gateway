variable "s3_bucket" {
  description = "Optional"
  type        = string
  default     = null
}




pipeline {
    agent any
  
    tools {
        terraform 'terraform'
    }
     environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }
    stages {
        stage ("checkout from GIT") {
            steps {
               git 'git_url'
               zip ../example.zip main.js
               export S3_BUCKET="terraform-serverless-example-<UNIQUE_ID>"
               aws s3api create-bucket --bucket=$S3_BUCKET --region=us-east-1
               aws s3 cp example.zip s3://$S3_BUCKET/v1.0.0/example.zip
            }
        }
        stage ("terraform init") {
            steps {
                sh 'terraform init'
            }
        }
        stage ("terraform validate") {
            steps {
                sh 'terraform validate'
            }
        }
        stage ("terrafrom plan") {
            steps {
                sh 'terraform plan '
            }
        }
        stage ("terraform apply") {
            steps {
                sh 'terraform apply --auto-approve -var s3_bucket=$S3_BUCKET'
            }
        }
    }
}
