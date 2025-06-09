#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 \
  --project   <TF_PROJECT_NAME> \
  --cluster   <EKS_CLUSTER_NAME> \
  --region    <AWS_REGION> \
  [--state-bucket <TF_STATE_BUCKET>] \
  [--lock-table   <TF_LOCK_TABLE>]

Tears down:
  • EKS node-groups & cluster (if present)
  • ECR repos: <project>-auth-service, <project>-frontend, <project>-nginx-gateway
  • Secrets Manager secrets named <project>-JWT_SECRET_KEY etc.
  • Terraform S3 state bucket
  • Terraform DynamoDB lock table
EOF
  exit 1
}

# --- parse args ---
TF_STATE_BUCKET=""
TF_LOCK_TABLE=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --project)      TF_PROJECT_NAME="$2"; shift 2;;
    --cluster)      TF_EKS_CLUSTER_NAME="$2"; shift 2;;
    --region)       AWS_REGION="$2"; shift 2;;
    --state-bucket) TF_STATE_BUCKET="$2"; shift 2;;
    --lock-table)   TF_LOCK_TABLE="$2"; shift 2;;
    *) usage;;
  esac
done

: "${TF_PROJECT_NAME:?--project is required}"
: "${AWS_REGION:?--region is required}"

# Defaults:
TF_STATE_BUCKET=${TF_STATE_BUCKET:-"${TF_PROJECT_NAME}-tf-state"}
TF_LOCK_TABLE=${TF_LOCK_TABLE:-"${TF_PROJECT_NAME}-tf-lock"}

echo "🗑️  Tearing down project '$TF_PROJECT_NAME' in region '$AWS_REGION'..."

# 1) EKS cluster & node-groups
if aws eks describe-cluster --name "$TF_EKS_CLUSTER_NAME" --region "$AWS_REGION" >/dev/null 2>&1; then
  echo "🔹 Deleting EKS node-groups in cluster $TF_EKS_CLUSTER_NAME..."
  NGS=$(aws eks list-nodegroups \
    --cluster-name "$TF_EKS_CLUSTER_NAME" \
    --region "$AWS_REGION" \
    --query "nodegroups[]" --output text || true)

  if [[ -n "$NGS" ]]; then
    for NG in $NGS; do
      echo "   • Deleting nodegroup $NG"
      aws eks delete-nodegroup \
        --cluster-name "$TF_EKS_CLUSTER_NAME" \
        --nodegroup-name "$NG" \
        --region "$AWS_REGION"
    done
    echo "⏳ Waiting for nodegroups to delete..."
    for NG in $NGS; do
      aws eks wait nodegroup-deleted \
        --cluster-name "$TF_EKS_CLUSTER_NAME" \
        --nodegroup-name "$NG" \
        --region "$AWS_REGION"
      echo "   ✓ $NG deleted"
    done
  else
    echo "   • No node-groups found"
  fi

  echo "🔹 Deleting EKS cluster $TF_EKS_CLUSTER_NAME..."
  aws eks delete-cluster \
    --name "$TF_EKS_CLUSTER_NAME" \
    --region "$AWS_REGION"
  echo "⏳ Waiting for cluster deletion..."
  aws eks wait cluster-deleted \
    --name "$TF_EKS_CLUSTER_NAME" \
    --region "$AWS_REGION"
  echo "   ✓ Cluster deleted"
else
  echo "⚠️  Cluster '$TF_EKS_CLUSTER_NAME' not found—skipping EKS teardown"
fi

# 2) ECR repos
echo "🔹 Deleting ECR repositories..."
for svc in auth-service frontend nginx-gateway; do
  REPO="${TF_PROJECT_NAME}-${svc}"
  echo "   • Deleting repo $REPO"
  aws ecr delete-repository \
    --repository-name "$REPO" \
    --region "$AWS_REGION" \
    --force || echo "     – Repo $REPO not found"
done

# 3) Secrets Manager
echo "🔹 Deleting Secrets Manager entries..."
for key in JWT_SECRET_KEY JWT_ALGORITHM DATABASE_URL REDIS_URL; do
  name="${key}"
  echo "   • Deleting secret $name"
  arn=$(aws secretsmanager list-secrets \
    --region "$AWS_REGION" \
    --include-planned-deletion \
    --query "SecretList[?Name=='$name'].ARN" \
    --output text || true)
  if [[ -n "$arn" ]]; then
    aws secretsmanager delete-secret \
      --secret-id "$arn" \
      --region "$AWS_REGION" \
      --force-delete-without-recovery
    echo "     ✓ $name removed"
  else
    echo "     – $name not found"
  fi
done

echo "✅ Teardown complete!"

