terraform init \
    -backend-config="bucket=jd95-main-tfstate" \
    -backend-config="key=state/lambda_s3.state" \
    -backend-config="region=us-east-2" \
    -backend-config="dynamodb_table=main-tfstatelock" \
    -backend-config="access_key=$ACCESS_KEY" \
    -backend-config="secret_key=$SECRET_KEY"
