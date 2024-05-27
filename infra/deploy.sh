#!/bin/bash

set -euo pipefail

STEPS="bootstrap_tf_state eks argocd"

for step in ${STEPS}
do
    echo
    echo Processing ${step}
    set -x
    cd ${step}
    terraform init
    terraform apply -auto-approve
    set +x
    cd ..
done