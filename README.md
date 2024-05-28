# ArgoCD EKS Demo App

This is an Infrastructure as Code project that will set up an EKS cluster, ArgoCD, and manage application deployment using GitOps principles. It streamlines the deployment of changes for a demo app consisting of 3 microservices.

## Overview

The project architecture includes the following components:

- **Terraform**: Used to create and manage AWS resources, including an EKS cluster.
- **S3**: Stores the remote state for Terraform.
- **EKS Cluster**: Hosts the Kubernetes cluster.
- **ArgoCD**: Manages the deployment of the microservices using GitOps principles.
- **Docker**: Containerizes the microservices.
- **CI/CD Pipeline**: Utilizes GitHub Actions to build and push Docker images to Docker Hub.

The pipeline flow:
1. A GitHub Actions pipeline build is triggered by any commit that changes the source code of any of the microservices.
2. The pipeline builds the Docker images and pushes them to Docker Hub.
3. Then it updates the Kubernetes manifests of the app with the tags of the new images.
4. The manifests in the repo are monitored by ArgoCD. This service ensures that the app is deployed in the EKS clusters, according to the manifest source.
5. When a change in the manifests is detected, ArgoCD reconciles the workloads in EKS to match these manifests.

This ensures a streamlined and automated process for deploying updates to the app.

**Note**: For simplicity, the deployment flow is integrated for all the app. Any change generates new images for all microservices with the same version tags. In a real environment, there would be an individual build flow and versioning for each component.

Project Structure:

- `src/`: Source code of the 3 microservices and Docker-related files to build images of them and push them to Docker Hub.
- `infra/`:
  - `bootstrap_tf_state/`: Terraform code to create the S3 bucket for remote state.
  - `eks/`: Terraform code to deploy the EKS cluster and associated resources.
  - `argocd/`: Terraform code to deploy ArgoCD in the EKS cluster.
    - `argocd-apps/`: ArgoCD Application manifests to track the app Kubernetes manifests.
- `k8s/`: Kubernetes manifests for the app.
- `.github/workflows/`: CI/CD pipeline code to build and push the app Docker images.
- `README.md`: Project documentation.

## Features

- **Infrastructure as Code**: Uses Terraform to manage AWS resources.
- **GitOps**: Uses ArgoCD to manage application deployments.
- **Microservices**: Includes a web UI and two REST APIs (weather service and temperature conversion service).
- **CI/CD Pipeline**: Automates the build and deployment process using GitHub Actions.
- **Scalable and Resilient**: Ensures the deployment is scalable and resilient to failures.

## Getting Started

The infrastructure script creates, in order:
- an S3 bucket to store the Terraform remote state
- a VPC and an EKS cluster, and all the resources associated to secure and provide connectivity inside and outside the cluster: managed nodes, security groups, policies, subnets, load balancer, public IP, etc.
- a workload for ArgoCD inside the cluster
- an ArgoCD application to deploy and track changes of the demo app

### Requirements

- AWS CLI
- Terraform
- Docker
- kubectl
- Docker Hub and GitHub credentials

### Quickstart

By following these steps, you will set up the infrastructure, deploy ArgoCD, and manage the application deployment using GitOps principles.

#### Step 0: Update Docker repositories in the Kubernetes templates

I've worked with my own Docker Hub repositories. To make the pipeline work with repos from a different user, you have to update the hardcoded Docker image names in the Kubernetes templates. I.e.:
```yaml
spec:
  template:
    spec:
      containers:
          image: ajarag/web-ui:0.1 # ajarag should be replaced by your Docker username
```

You can do that with
```sh
export DOCKER_USERNAME=<YOUR_DOCKER_USERNAME>
for dir in k8s/*/; do
  component=$(basename ${dir})
  sed -i "s|image: [^/]*/\(.*\)|image: ${DOCKER_USERNAME}/\1|" \
    k8s/${component}/deployment.yaml
done
```

**Important**: *Commit these changes to the main branch*.

#### Step 1: Set up Docker Credentials in GitHub Actions

Add the following secrets to your repo *Settings/Secrets and Variables/Actions*:
- `DOCKER_USERNAME`: Your Docker Hub username
- `DOCKER_PASSWORD`: Your Docker Hub password

#### Step 2: Set up AWS Credentials

Configure your AWS credentials using the AWS CLI:
```sh
aws configure
```

#### Step 3: Create a Github token

Assuming this repository is private, authentication needs to be set up to allow ArgoCD access to it. A GitHub Personal Access Token (PAT) with access only to this repository can be used for this purpose.

Check out [here](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-fine-grained-personal-access-token) the instructions on how to create the token. A read-only access to contents permission is enough for the token.

Export the token as an environment variable
```sh
export GITHUB_TOKEN=<YOUR_GITHUB_TOKEN>
```

#### Step 3: Deploy the Infrastructure with Terraform

Navigate to the `infra/` directory and run:
```sh
cd infra/
./deploy.sh
```

That's it. Check the script output to see the app deployed. The app pods will appear shortly
```sh
export KUBECONFIG=./argocd-demo-cluster-kubeconfig.yaml
kubectl get all -n demo-app
```
You can see it in the ArgoCD UI as well. The endpoint and credentials are also in the script output.

### Trigger the Pipeline

Now each change in the app source code will automatically end up deployed in the EKS cluster.

To test this, make a change inside the `src/` directory and commit it to the main branch. You should see a build of the pipeline running in the Github Actions tab, creating the new Docker images and updating the tags in the manifests monitored by ArgoCD.

After a while, you should see how ArgoCD updates the workloads in the cluster with the new updated images. For instance:
```sh
kubectl get pod -n demo-app -o yaml | grep image:
```
