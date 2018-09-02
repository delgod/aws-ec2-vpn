#!/bin/bash

. $(dirname $0)/vars

set -o errexit
set -o xtrace

if [ -z "${vpn_pre_shared_key// }" -o -z "${vpn_username// }" -o -z "${vpn_password// }" ]; then
    vpn_pre_shared_key=$1
    vpn_username=$2
    vpn_password=$3
fi

aws cloudformation create-stack \
    --profile ${profile} \
    --region $region \
    --stack-name $stack_name \
    --template-body file://aws-ec2-vpn.yml \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
    --parameters \
    ParameterKey=MasterKeyName,ParameterValue=$ssh_key \
    ParameterKey=VpnPreSharedKey,ParameterValue=$vpn_pre_shared_key \
    ParameterKey=VpnUserName,ParameterValue=$vpn_username \
    ParameterKey=VpnPassword,ParameterValue=$vpn_password

echo "VPN Setup in progress."

aws cloudformation wait stack-create-complete \
    --profile ${profile} \
    --region $region \
    --stack-name $stack_name

ip=$(
    aws cloudformation describe-stacks \
        --profile ${profile} \
        --region $region \
        --stack-name $stack_name \
        --query 'Stacks[0].Outputs[0].OutputValue' \
        --output text
)

echo "VPN Setup complete. IP address is '$ip'."
