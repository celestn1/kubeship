
# KubeShip

KubeShip is a production-ready, GitOps-based Kubernetes platform built with **Amazon EKS**, **ArgoCD**, **Terraform**, and **Helm**. It deploys a full-stack microservices application including frontend, API gateway, PostgreSQL, and Redis.

---

## Features

- ✅ Infrastructure as Code (Terraform)
- ✅ GitOps Continuous Delivery (ArgoCD)
- ✅ Kubernetes-native Helm deployments
- ✅ CI/CD with GitHub Actions
- ✅ PostgreSQL + Redis backend services
- ✅ React + FastAPI full-stack application
- ✅ Secure, autoscaling EKS cluster
- ✅ Prometheus & Grafana monitoring

---

## Architecture

![KubeShip Architecture](./kubeship_architecture_diagram.png)

---

## Tech Stack

| Layer         | Tool                        |
|---------------|-----------------------------|
| IaC           | Terraform                   |
| GitOps        | ArgoCD                      |
| Kubernetes    | Amazon EKS                  |
| CI/CD         | GitHub Actions              |
| Packaging     | Helm                        |
| Container Registry | Amazon ECR             |
| Backend       | FastAPI, PostgreSQL, Redis  |
| Frontend      | React + Vite / Next.js      |
| Monitoring    | Prometheus + Grafana        |

---

## 📁 Project Structure

```
kubeship/
├── terraform/              # Infrastructure provisioning
├── helm-charts/            # Helm charts for each service
├── microservices/
│   ├── api-gateway/        # FastAPI Gateway
│   ├── auth-service/       # JWT Auth Service
│   └── frontend/           # React or Next.js App
├── manifests/              # ArgoCD projects and apps
└── .github/workflows/      # CI pipelines
```

---

## Quick Start

### 1. Provision Infrastructure

```bash
cd terraform
terraform init
terraform apply
```

### 2. Access ArgoCD

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
```

Visit https://localhost:8080 and login with `admin`.

### 3. Build & Push Docker Images

```bash
docker build -t <your-ecr-repo>/api-gateway:latest ./microservices/api-gateway
docker push <your-ecr-repo>/api-gateway:latest
```

### 4. Deploy via Helm + ArgoCD

Update `helm-charts/<service>/values.yaml` with your image and config.

ArgoCD will automatically sync and deploy to EKS.

---

## Observability

Install Prometheus stack:

```bash
helm install kube-prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```

Access Grafana:

```bash
kubectl port-forward svc/kube-prometheus-grafana -n monitoring 3000:80
```

---

## Resources

- [ArgoCD](https://argo-cd.readthedocs.io/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws)
- [Helm](https://helm.sh/)
- [AWS EKS Docs](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html)

---

## TODO

- [ ] Add domain support via cert-manager + Route 53
- [ ] Implement secrets management with Sealed Secrets
- [ ] Enable horizontal pod autoscaling
- [ ] Add staging/prod environments

---

## Author

Made with ❤️ by Celestine — [GitHub](https://github.com/celestn1)

Contributions welcome!
