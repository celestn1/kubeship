#!/usr/bin/env bash
set -euo pipefail

# Adjust these to match your project
PROJECT=kubeship
REGION=eu-west-2
CLUSTER_NAME=kubeship-cluster
NODEGROUP_NAME=default-20250612035232168600000001

# echo "👉 1) Delete the EKS managed nodegroup"
#  aws eks delete-nodegroup \
#  --cluster-name "$CLUSTER_NAME" \
#  --nodegroup-name "$NODEGROUP_NAME" \
#  --region "$REGION"

echo "   …waiting for nodegroup to disappear…"
aws eks wait nodegroup-deleted \
  --cluster-name "$CLUSTER_NAME" \
  --nodegroup-name "$NODEGROUP_NAME" \
  --region "$REGION"

echo "👉 2) Delete the EKS cluster"
aws eks delete-cluster \
  --name "$CLUSTER_NAME" \
  --region "$REGION"

echo "   …waiting for cluster to disappear…"
aws eks wait cluster-deleted \
  --name "$CLUSTER_NAME" \
  --region "$REGION"

echo "👉 3) Delete the ALB created by Terraform (if any)"
ALB_ARN=$(aws elbv2 describe-load-balancers \
  --names "${PROJECT}-alb" \
  --region "$REGION" \
  --query 'LoadBalancers[0].LoadBalancerArn' \
  --output text 2>/dev/null || echo "")
if [[ -n "$ALB_ARN" && "$ALB_ARN" != "None" ]]; then
  aws elbv2 delete-load-balancer --load-balancer-arn "$ALB_ARN" --region "$REGION"
fi

echo "👉 4) Delete ECR repositories"
for repo in auth-service frontend nginx-gateway; do
  aws ecr delete-repository \
    --repository-name "${PROJECT}-$repo" \
    --force \
    --region "$REGION" || true
done

echo "👉 5) Delete Secrets Manager secrets tagged Project=$PROJECT"
for arn in $(aws secretsmanager list-secrets \
    --filters Key=tag-key,Values=Project Key=tag-value,Values=$PROJECT \
    --region "$REGION" \
    --query 'SecretList[].ARN' \
    --output text); do
  aws secretsmanager delete-secret \
    --secret-id "$arn" \
    --force-delete-without-recovery \
    --region "$REGION"
done

echo "👉 6) Delete the VPC and all its children by tag"
VPC_ID=$(aws ec2 describe-vpcs \
  --filters "Name=tag:Project,Values=$PROJECT" \
  --region "$REGION" \
  --query 'Vpcs[0].VpcId' \
  --output text)
if [[ -n "$VPC_ID" && "$VPC_ID" != "None" ]]; then
  echo "   • Detaching & deleting IGW"
  IGW_ID=$(aws ec2 describe-internet-gateways \
    --filters "Name=attachment.vpc-id,Values=$VPC_ID" \
    --region "$REGION" \
    --query 'InternetGateways[0].InternetGatewayId' \
    --output text)
  aws ec2 detach-internet-gateway --internet-gateway-id "$IGW_ID" --vpc-id "$VPC_ID" --region "$REGION"
  aws ec2 delete-internet-gateway  --internet-gateway-id "$IGW_ID" --region "$REGION"

  echo "   • Deleting NAT gateways"
  for nat in $(aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$VPC_ID" \
      --region "$REGION" --query 'NatGateways[].NatGatewayId' --output text); do
    aws ec2 delete-nat-gateway --nat-gateway-id "$nat" --region "$REGION"
  done

  echo "   • Deleting subnets"
  for sn in $(aws ec2 describe-subnets --filter "Name=vpc-id,Values=$VPC_ID" \
      --region "$REGION" --query 'Subnets[].SubnetId' --output text); do
    aws ec2 delete-subnet --subnet-id "$sn" --region "$REGION" || true
  done

  echo "   • Deleting route tables"
  for rt in $(aws ec2 describe-route-tables --filter "Name=vpc-id,Values=$VPC_ID" \
      --region "$REGION" --query 'RouteTables[].RouteTableId' --output text); do
    aws ec2 delete-route-table --route-table-id "$rt" --region "$REGION" || true
  done

  echo "   • Finally deleting the VPC"
  aws ec2 delete-vpc --vpc-id "$VPC_ID" --region "$REGION"
fi

echo "✅  All project‐scoped AWS resources have been cleaned up."

