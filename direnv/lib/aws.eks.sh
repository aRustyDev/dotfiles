for cluster in `aws eks list-clusters`; do
    json=$(aws eks describe-cluster --name $cluster | jq '.')
    aws eks update-kubeconfig \
        --name $cluster \
        --endpoint-url $(echo $json | jq '.') \
        --alias $alias \
        --user-alias $user \
        --assume-role-arn $role \
        --role-arn $role
done
