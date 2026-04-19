#!/bin/bash

ENV=${1:-"dev"}
DIR="terraform/environments/${ENV}"

echo "Initializing terraform"
terraform -chdir=$DIR init