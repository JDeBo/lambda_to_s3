node {
    // stage('Clone') { // for display purposes
    //     // Clone the configurations repository
    //     cleanWs()
    //     git 'https://github.com/JDeBo/lamda_to_s3.git'   
    // }
    stage('List-files') {
        // List git files
        sh script: 'ls -lah'
    }
    stage('Download') {
        // Download Terraform
        sh label: '', script: 'curl https://releases.hashicorp.com/terraform/0.12.29/terraform_0.12.29_linux_amd64.zip \
            --output terraform_0.12.29_darwin_amd64.zip \
             && unzip terraform_0.12.29_darwin_amd64.zip'
    }
    stage('Config-Init') {
        withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                        string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
                            dir('lambda_to_s3') {
                                sh script: '../terraform init \
                                            -backend-config="bucket=jd95-main-tfstate" \
                                            -backend-config="key=state/terraform.state" \
                                            -backend-config="region=us-east-2" \
                                            -backend-config="dynamodb_table=main-tfstatelock" \
                                            -backend-config="access_key=$aws_access_key" \
                                            -backend-config="secret_key=$aws_secret_key"'
                            }
                        }
    }
    stage('Config-Plan') {
        // Generate Terraform plan
        withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                        string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
                            dir('lambda_to_s3') {
                                sh script: '../terraform plan \
                                            -out lamda.tfplan \
                                            -var="aws_access_key=$aws_access_key" \
                                            -var="aws_secret_key=$aws_secret_key"'
                            }
        }
    }
    stage('Config-Apply') {
        // Apply the configuration
        withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                        string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
                            dir('lambda_to_s3') {
                                sh script: '../terraform apply lamda.tfplan'
                            }
        }
    }
    stage('Destroy'){
        input 'Destroy?'
        withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                        string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
            dir('lambda_to_s3') {
                sh script: '../terraform destroy \
                        -auto-approve \
                        -var="aws_access_key=$aws_access_key" \
                        -var="aws_secret_key=$aws_secret_key"'
            }
        }
    }
}