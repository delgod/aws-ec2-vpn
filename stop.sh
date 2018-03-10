#!/bin/sh

. $(dirname $0)/vars

set -o errexit
set -o xtrace

aws cloudformation delete-stack \
    --profile ${profile} \
    --region ${region} \
    --stack-name ${stack_name}
