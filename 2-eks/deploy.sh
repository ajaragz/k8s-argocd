#!/bin/bash

set -euxo pipefail

# Get kube config with
#  aws eks --region $(terraform output -raw region) update-kubeconfig \
#    --name $(terraform output -raw cluster_name) \
#    --kubeconfig "${KUBECONFIG_DIR}/$(terraform output -raw cluster_name).yaml"
# Output file may differ depending on your setting

terraform init
terraform apply
