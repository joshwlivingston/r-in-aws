#!/bin/bash

ENV=${1:-"dev"}
DIR="terraform/environments/${ENV}"

echo "Validating ECR Repository"
terraform -chdir=$DIR apply -target=module.ecr -auto-approve
