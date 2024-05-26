# ArgoCD_EKS_demo_app

This is an Infrastructure as Code project using Terraform to create an AWS Kubernetes EKS cluster. The remote state for Terraform is stored in an S3 bucket. ArgoCD is integrated into the cluster to deploy a demo app consisting of three microservices: a web UI and two REST APIs. All code is stored in the same GitHub repository.

## Overview

The project architecture includes the following components:

- **Terraform**: Used to create and manage AWS resources, including an EKS cluster.
- **S3**: Stores the remote state for Terraform.
- **EKS Cluster**: Hosts the Kubernetes cluster.
- **ArgoCD**: Manages the deployment of the microservices using GitOps principles.
- **Docker**: Containerizes the microservices.
- **CI/CD Pipeline**: Utilizes GitHub Actions to build and push Docker images to Docker Hub.

### Project Structure

- `1-bootstrap_tf_state/`: Terraform code to create the S3 bucket for remote state.
- `2-eks/`: Terraform code to deploy the EKS cluster and associated resources.
- `src/`: Contains the microservices and Docker-related files.
- `.github/workflows/`: Contains the CI/CD pipeline configuration.
- `README.md`: Project documentation.

## Features

- **Infrastructure as Code**: Uses Terraform to manage AWS resources.
- **GitOps**: Uses ArgoCD to manage application deployments.
- **Microservices**: Includes a web UI and two REST APIs (weather service and temperature conversion service).
- **CI/CD Pipeline**: Automates the build and deployment process using GitHub Actions.
- **Scalable and Resilient**: Ensures the deployment is scalable and resilient to failures.

## Getting started

### Requirements

- AWS CLI
- Terraform
- Docker
- kubectl
- Python 3.x
- GitHub account to store Docker Hub credentials as secrets in the repository

### Quickstart

#### Step 1: Set up AWS Credentials

Configure your AWS credentials using the AWS CLI:

```sh
aws configure
```

#### Step 2: Bootstrap Terraform Remote State

Navigate to the `1-bootstrap_tf_state/` directory and run:

```sh
cd 1-bootstrap_tf_state/
./deploy.sh
```

#### Step 3: Deploy EKS Cluster

Navigate to the `2-eks/` directory and run:

```sh
cd ../2-eks/
./deploy.sh
```

#### Step 4: Build and Push Docker Images

Set your Docker Hub username and image tag:

```sh
export DOCKER_USER=<your_dockerhub_username>
export IMAGE_TAG=latest
```

Navigate to the `src/` directory and run the build script for each microservice:

```sh
cd ../src/
./build_push.sh web-ui
./build_push.sh weather-service
./build_push.sh temp-conversion-service
```

#### Step 5: Deploy Microservices Using ArgoCD

ArgoCD will automatically detect changes in the manifests and deploy the updated application in the cluster.

## License

Copyright (c) 2024.
