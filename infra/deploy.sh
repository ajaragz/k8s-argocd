#!/bin/bash

set -euo pipefail

# Deployment script for
# - TF state
# - EKS
# - ArgoCD
# - ArgoCD Application resource for the demo app
#
#
# Export your Github Token with read access to the repository and run with
# ```
#   export GITHUB_TOKEN=<YOUR_PERSONAL_ACCESS_TOKEN>
#   ./deploy.sh
# ```

KUBECONFIG_DIR=$(pwd)
GITHUB_TOKEN="${GITHUB_TOKEN}"

# Deployment of EKS and ArgoCD
TF_STEPS="bootstrap_tf_state eks argocd"
for step in ${TF_STEPS}
do
    echo
    echo Processing ${step}
    set -x
    cd ${step}
    terraform init
    terraform apply -auto-approve
    set +x
    cd ..
    sleep 30 # let the resources get ready for the next step
done

# Obtain EKS credentials
cd eks
KUBECONFIG="${KUBECONFIG_DIR}/$(terraform output -raw cluster_name)-kubeconfig.yaml"
aws eks --region $(terraform output -raw region) update-kubeconfig \
    --name $(terraform output -raw cluster_name) \
    --kubeconfig "${KUBECONFIG}"
echo

kubectl cluster-info
echo

# ArgoCD Application resource deployment
cd ..
sed -e "s/GITHUB_TOKEN/${GITHUB_TOKEN}/g" argocd/argocd-apps/repo-secret.yaml \
    | kubectl apply -f -
kubectl apply -f argocd/argocd-apps/demo-app.yaml

# Show resources and ArgoCD endpoint
echo
echo ArgoCD application status
kubectl get app -n argocd

echo
echo -n 'ArgoCI UI endpoint: '
echo https://$(kubectl get service -n argocd argocd-server \
    -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo -n 'ArgoCD admin password: '
echo $(kubectl get secrets -n argocd argocd-initial-admin-secret \
    -o jsonpath='{.data.password}' | base64 --decode)
