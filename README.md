
# Project: KubeShip – GitOps Platform with ArgoCD and EKS

## What Is KubeShip?

**KubeShip** is a real-world GitOps platform that automates the deployment and management of containerized applications using:

- **Amazon EKS** for Kubernetes orchestration
- **ArgoCD** for GitOps-based continuous delivery
- **Terraform** for infrastructure as code
- **Helm** for Kubernetes packaging
- **GitHub Actions** for CI pipelines
- **React + FastAPI** for microservices
- **PostgreSQL + Redis** for backend storage

This project shows how modern teams deploy applications at scale with automation and best DevOps practices.

---

## Why KubeShip?

Because deploying microservices manually doesn’t scale. You need:

- Declarative infrastructure (Terraform)
- Automated provisioning (EKS)
- GitOps deployment model (ArgoCD)
- CI/CD pipelines (GitHub Actions)
- Monitoring and scalability

KubeShip combines all of these in one integrated stack.

---

## Architecture Overview

### Core Components

| Layer             | Tool                         |
|-------------------|------------------------------|
| Infra Provision   | Terraform                    |
| Cluster           | Amazon EKS                   |
| GitOps CD         | ArgoCD                       |
| Helm Packaging    | Helm                         |
| CI/CD             | GitHub Actions               |
| Container Registry| Amazon ECR                   |
| Microservices     | FastAPI, React, PostgreSQL   |
| Monitoring        | Prometheus + Grafana         |

---

## Architecture Diagram

```
                        ┌──────────────────────────────┐
                        │     GitHub Repo (IaC + App)  │
                        └────────────┬─────────────────┘
                                     │ Push
                          ┌──────────▼──────────┐
                          │    GitHub Actions   │────────────┐
                          └──────────┬──────────┘            │
                                     │ Image Build/Push      │
                          ┌──────────▼──────────┐            │
                          │    Amazon ECR       │            │
                          └─────────────────────┘            │
                                                             ▼
                                               ┌────────────────────────┐
                                               │   Amazon EKS Cluster   │
                                               │   (Provisioned via TF) │
                                               └──────────┬─────────────┘
                                                          │
                                                ┌─────────▼─────────┐
                                                │     ArgoCD        │
                                                │  (GitOps CD Tool) │
                                                └──────┬────────────┘
                                                       │
                                           ┌───────────▼────────────┐
                                           │   Helm Deployments      │
                                           │  (Frontend, API, Redis) │
                                           └─────────────────────────┘
```

---

## Project Structure

```
kubeship/
├── terraform/              # VPC + EKS via Terraform
├── microservices/          # React + FastAPI + DB
│   ├── api-gateway/
│   ├── auth-service/
│   └── frontend/
├── helm-charts/            # Helm charts per service
├── manifests/              # ArgoCD apps and projects
└── .github/workflows/      # CI build and push pipelines
```

---

## Infrastructure Provisioning with Terraform

Provision:

- VPC with public and private subnets
- NAT Gateway for outbound traffic
- Amazon EKS cluster
- IAM roles and node groups

Modules used:
- `terraform-aws-modules/vpc/aws`
- `terraform-aws-modules/eks/aws`

Command:

```bash
terraform init
terraform apply
```

---

## GitOps with ArgoCD

ArgoCD tracks:
- Git repo for Helm chart changes
- Helm charts from `helm-charts/`
- Syncs them to EKS cluster

To access ArgoCD:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Open: [https://localhost:8080](https://localhost:8080)

---

## CI/CD with GitHub Actions

- Builds Docker images
- Pushes to ECR
- ArgoCD picks up and syncs latest deployment

CI defined in: `.github/workflows/deploy.yaml`

---

## Testing and Observability

Post-deployment:

- Validate apps in ArgoCD UI
- `kubectl get pods -A` for health checks
- Test endpoints using ALB DNS

Monitoring with Prometheus + Grafana (optional):

```bash
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```

---

## ✅ Real-World Problem Solving

| Concern                    | KubeShip Solution               |
|----------------------------|----------------------------------|
| Scalable Deployments       | GitOps + ArgoCD                 |
| CI/CD                      | GitHub Actions + ECR            |
| Infra as Code              | Terraform                       |
| Secrets + Networking       | EKS best practices              |
| Observability              | Prometheus + Grafana            |

---

## What’s Next?

- [ ] Add custom domain with cert-manager + Route 53
- [ ] Use Sealed Secrets or External Secrets
- [ ] Setup staging and prod ArgoCD environments
- [ ] Enable autoscaling (HPA)

---

## Summary

KubeShip lets you:

✅ Learn GitOps & EKS  
✅ Use Terraform professionally  
✅ Automate deployments  
✅ Build full-stack apps in Kubernetes

---

## Author

Built with ❤️ by Celestine — [GitHub](https://github.com/celestn1)
