# aws-eks-cicd-rollback-guard

## Overview
CI/CD pipeline for Kubernetes on AWS EKS featuring automated canary deployments and rollback mechanisms. Hybrid local (kind) and AWS EKS deployment notes.

This repository is provided as a hybrid demonstration: it is fully runnable in a local development environment (Docker, kind/minikube, Terraform local provider) and annotated with production migration guidance for AWS EKS. The deployment flow and validation described in this README were tested locally with kind before AWS EKS rollout.

## Architecture
An architecture diagram is included at `assets/architecture.png`. The diagram depicts control plane separation, CI/CD flow, and monitoring paths. Key architectural choices are justified in the Implementation Details section.

## Tech Stack
- Container runtime: Docker
- Local Kubernetes: kind (validation); manifests are compatible with AWS EKS
- CI/CD: GitHub Actions (examples) and Jenkins (where applicable)
- IaC: Terraform (local provider + AWS examples)
- Config: Ansible (post-provision)
- Secrets: HashiCorp Vault (dev-mode included for local testing) or cloud secret manager in production
- Monitoring: Prometheus-compatible metrics and Alertmanager (conceptual). CloudWatch integration notes included.

## Implementation Details
The repository contains modular directories for code, manifests, automation, and logs:
- `app/` or `docker/` — application source and Dockerfile
- `k8s/` — Kubernetes manifests organized for dev/staging/prod
- `terraform/` — IaC with comments for local and AWS providers
- `ansible/` — configuration management playbooks
- `scripts/` — utility scripts (deploy, simulate incidents, rollback, bootstrap)
- `logs/` — command-line style logs demonstrating runs, alerts, and remediation

### Local Quickstart (Ubuntu / WSL2)
1. Install prerequisites: Docker, kind, kubectl, Terraform, Ansible (as relevant).
2. Create local kind cluster:
   ```bash
   kind create cluster --name demo-eks
   ```
3. Build and load the local image:
   ```bash
   docker build -t demo-app:latest app/
   kind load docker-image demo-app:latest --name demo-eks
   ```
4. Deploy manifests:
   ```bash
   kubectl apply -f k8s/
   ```
5. Validate rollout and simulate incidents:
   ```bash
   bash scripts/simulate-error.sh
   tail -f logs/deployment_pipeline.log
   ```

### AWS EKS Migration Notes
- Replace local images with ECR repository references and set up IAM roles for EKS node groups.
- Use Terraform AWS provider to provision EKS, ECR, and IAM resources; migrate terraform backend to S3 with DynamoDB state lock.
- Configure IRSA for pods that need AWS permissions and integrate Vault or AWS Secrets Manager for secret injection.
- For production observability, use Prometheus Operator or AWS Managed Prometheus and adjust retention and alerting rules accordingly.

## CI/CD Workflow
Typical pipeline stages:
1. Build: Docker image build and unit test stage.
2. Publish: Push to ECR in AWS mode; load image into local kind for validation in dev mode.
3. Deploy: Apply Kubernetes manifests.
4. Canary: Validate canary replica and metrics.
5. Rollback: Automated rollback triggered by alert thresholds (scripts provided in `scripts/`).

## Security and Observability
- Secrets are not committed. A Vault dev bootstrap script is provided for local evaluation; production requires Vault in HA mode or cloud secret manager.
- Readiness and liveness probes are used to drive automated remediation workflows.
- Logs under `logs/` are command-line style extracts demonstrating realistic operational output.

## Challenges and Resolutions
Representative examples of operational challenges and mitigation:
- Canary validation without a service mesh: implemented label-based canary deployments and synthetic traffic validation; recommended production migration to a service mesh for deterministic control.
- Alert noise: tuned scrape intervals and alert thresholds to reduce flapping during load tests.
- Secret lifecycle: adopted short-lived Vault tokens for build agents to reduce credential exposure.

## Future Work
- Integrate service mesh for deterministic traffic splitting.
- Add automated chaos testing to validate resilience.
- Harden RBAC and network policies for cluster isolation.

## Repository Structure
- `app/`
- `k8s/`
- `terraform/`
- `ansible/`
- `scripts/`
- `logs/`
- `assets/architecture.png`

Author: Dhairyashil Bhosale
GitHub: https://github.com/devopsbydhairyashil
LinkedIn: https://www.linkedin.com/in/dhairyashilclouddevops/
Last updated: 2025-10-27
