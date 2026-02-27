# Renew AWS Credentials
if [[ -n $IS_TERRAGRUNT ]]; then
    AWS_DEFAULT_REGION="us-east-1"
    AWS_PROFILE="c4p-ite-devops-admin"
    aws-sso -config ~/.config/aws-sso/gov.yaml
fi
