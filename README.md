# ArgoCD EKS demo app

This is an Infrastructure as Code project using Terraform to integrate a GitOps CD pipeline based on EKS, ArgoCD and Github Actions. It streamlines the deployment of changes of a demo app consisting of 3 microservices.

## Overview

The project architecture includes the following components:

- **Terraform**: Used to create and manage AWS resources, including an EKS cluster.
- **S3**: Stores the remote state for Terraform.
- **EKS Cluster**: Hosts the Kubernetes cluster.
- **ArgoCD**: Manages the deployment of the microservices using GitOps principles.
- **Docker**: Containerizes the microservices.
- **CI/CD Pipeline**: Utilizes GitHub Actions to build and push Docker images to Docker Hub.

All these together implement a GitOps CD pipeline with the following flow:
1. A Github Actions pipeline build is triggered by any commit .that changes source code of any of the microservices
2. The pipeline builds the Docker images and push them to Docker Hub.
3. Then it updates the Kubernetes manifests of the app with the tags of the new images.
4. The manifests in the repo are monitored by ArgoCD. This service ensures that the app is deployed in the EKS clusters, according to the manifests source.
5. When a change in the manifests is detected. ArgoCD reconciles the workloads in EKS to match these manifest.

This flow ensures that a change in the code of the app end up automatically deployed in the EKS cluster

**Note**: *for simplicity, the deployment flow is integrated for all the app. Any change generates new images for all microservices. With the same version tags. In a real environment, there would be an individual build flow and versioning for each component.*

### Project Structure

- `src/`: Source code of the 3 microservices and Docker-related files to build images of them and push them to Docker Hub.
- `infra/`:
    - `bootstrap_tf_state/`: Terraform code to create the S3 bucket for remote state.
    - `eks/`: Terraform code to deploy the EKS cluster and associated resources.
    - `argocd`: Terraform code to deploy ArgoCD in the EKS cluster.
- `k8s`: Kubernetes manifests for the app.
- `argocd-apps`: ArgoCD Application manifests to track the app Kubernetes manifests.
- `.github/workflows/`: CI/CD pipeline code to build and push the app docker images.
- `README.md`: Project documentation.

## Features

- **Infrastructure as Code**: Uses Terraform to manage AWS resources.
- **GitOps**: Uses ArgoCD to manage application deployments.
- **Microservices**: Includes a web UI and two REST APIs (weather service and temperature conversion service).
- **CI/CD Pipeline**: Automates the build and deployment process using GitHub Actions.
- **Scalable and Resilient**: Ensures the deployment is scalable and resilient to failures.

## Getting started

The infrastructure script creates in order:
- an S3 bucket to store the Terraform remote state
- a VPC and an EKS cluster
- a workload for ArgoCD inside the cluster

### Requirements

- AWS CLI
- Terraform
- Docker
- kubectl
- Docker Hub and Github credentials

### Quickstart

#### Step 1: Set up Docker credentials in Github Actions

Add the following secrets to your repo *Settings/Secrets and Variables/Actions*
```yaml
DOCKER_USERNAME: <YOUR_DOCKER_USERNAME>
DOCKER_PASSWORD: <YOUR_DOCKER_PASSWORD>
```

#### Step 2: Set up AWS Credentials

Configure your AWS credentials using the AWS CLI:

```sh
aws configure
```

#### Step 3: Deploy the Infrastructure with Terraform

Navigate to the `infra/` directory and run:

```sh
cd infra/
./deploy.sh
```

Once the script if finished, you can get the credentials to access the cluster with:
```sh
cd infra/eks
aws eks --region $(terraform output -raw region) update-kubeconfig \
    --name $(terraform output -raw cluster_name) \
    --kubeconfig "${KUBECONFIG_DIR}/$(terraform output -raw cluster_name).yaml"
```
The output file path may differ depending on your setting

Obtain the endpoint the admin password of the ArgoCD UI
```sh
echo https://`kubectl get service -n argocd argocd-server \
    -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'`
echo `kubectl get secrets argocd-initial-admin-secret -o yaml \
    -n argocd -o jsonpath='{.data.password}' | base64 --decode`
```
and check that service is alive.

#### Step 4: Deploy the App Using ArgoCD

If this repository is private, authentication needs to be setup to allow ArgoCD access to it. A Github Personal Access Token (PAT) with access only to this repository can be used for this purpose.

Check out [here](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-fine-grained-personal-access-token) the instructions on how to create the token. A read-only access to contents permission is enough for the token.

Apply the Secret manifest to store the repository access token with:
```sh
export GITHUB_TOKEN=<YOUR_PERSONAL_ACCESS_TOKEN>
sed -e "s/GITHUB_TOKEN/${GITHUB_TOKEN}/g" argocd-app/repo-secret.yaml \
    | kubectl apply -f -
```

Apply the ArgoCD Application manifest to create the Application in ArgoCD:
```sh
kubectl apply -f argocd-app/demo-app.yaml
```

After this, you should see that the ArgoCD application for this app is deployed with
```sh
kubectl get app -n argocd
```
and the workloads of the app are deployed as well
```sh
kubectl get all -n demo-app
```

#### Step 4: Trigger the pipeline

Make a change inside the `src/` directory and commit it to the main branch. You should see a build of the [pipeline](https://github.com/ajaragz/k8s-argocd/actions) running creating the new Docker images and updating the tags.

After a while, you should see how ArgoCD updates the workloads in the cluster with the new updated images. For instance
```sh
kubectl get pod -n demo-app -o yaml | grep image:
```
