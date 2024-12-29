# E-commerce Platform Deployment Guide

This guide explains how to deploy the e-commerce platform to AWS using Terraform and Kubernetes.

## Prerequisites

1. AWS Account with appropriate permissions
2. AWS CLI installed and configured
3. kubectl installed
4. Terraform installed
5. GitHub account with access to the repositories

## Repository Structure

```
ecommerce-deployment/
├── k8s/
│   ├── base/              # Base Kubernetes configurations
│   └── overlays/
│       ├── development/   # Development environment overrides
│       ├── staging/       # Staging environment overrides
│       └── production/    # Production environment overrides
├── terraform/
│   ├── modules/          # Reusable Terraform modules
│   └── environments/
│       ├── staging/      # Staging infrastructure
│       └── production/   # Production infrastructure
└── .github/
    └── workflows/        # CI/CD pipelines
```

## Environment Setup

### 1. AWS Configuration

1. Create an AWS IAM user with appropriate permissions
2. Configure AWS credentials:
   ```bash
   aws configure
   ```

### 2. GitHub Secrets

Add the following secrets to your GitHub repository:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

## Deployment Process

### Manual Deployment

1. **Initialize Terraform:**
   ```bash
   cd terraform/environments/<environment>
   terraform init
   ```

2. **Apply Infrastructure:**
   ```bash
   terraform apply -var="cluster_name=ecommerce-<environment>"
   ```

3. **Configure kubectl:**
   ```bash
   aws eks update-kubeconfig --name ecommerce-<environment> --region <region>
   ```

4. **Deploy Kubernetes Resources:**
   ```bash
   cd k8s/overlays/<environment>
   kustomize build . | kubectl apply -f -
   ```

### Automated Deployment

The repository includes GitHub Actions workflows that automatically deploy:
- Push to `main` branch → Production deployment
- Push to `staging` branch → Staging deployment

## Environment Specifications

### Staging Environment
- Minimal resource allocation for cost optimization
- Single replica for stateful services
- Spot instances for EKS nodes
- Autoscaling: 1-2 replicas
- Suitable for testing and QA

### Production Environment
- High availability configuration
- Multi-AZ deployment
- On-demand instances for reliability
- Autoscaling: 3-10 replicas
- Regular backups
- Full monitoring suite

## Monitoring and Maintenance

1. **Access Kubernetes Dashboard:**
   ```bash
   kubectl port-forward svc/kubernetes-dashboard -n kubernetes-dashboard 8080:443
   ```

2. **View Logs:**
   ```bash
   kubectl logs -f deployment/<deployment-name> -n ecommerce-<environment>
   ```

3. **Check Service Status:**
   ```bash
   kubectl get pods,svc,ing -n ecommerce-<environment>
   ```

## Cost Optimization

1. **Staging Environment:**
   - Uses spot instances
   - Minimal replicas
   - Smaller instance types
   - Estimated cost: ~$150-200/month

2. **Production Environment:**
   - Uses on-demand instances
   - High availability setup
   - Larger instance types
   - Estimated cost: ~$800-1000/month

## Troubleshooting

1. **Pod Issues:**
   ```bash
   kubectl describe pod <pod-name> -n ecommerce-<environment>
   ```

2. **Service Issues:**
   ```bash
   kubectl describe service <service-name> -n ecommerce-<environment>
   ```

3. **Infrastructure Issues:**
   ```bash
   terraform plan 
   ```

## Rollback Procedure

1. **Kubernetes Rollback:**
   ```bash
   kubectl rollout undo deployment/<deployment-name> -n ecommerce-<environment>
   ```

2. **Infrastructure Rollback:**
   ```bash
   terraform plan -target=<resource> # Review changes
   terraform apply -target=<resource> # Apply specific rollback
   ```

## Security Considerations

1. Network security through VPC configuration
2. Pod security policies enabled
3. RBAC for Kubernetes access
4. Secrets management through AWS Secrets Manager
5. Regular security updates

## Backup and Recovery

1. **Database Backups:**
   - RDS automated backups
   - Point-in-time recovery enabled

2. **State Recovery:**
   - Terraform state in S3
   - Version control for all configurations


## Future Improvements

1. Implement GitOps with ArgoCD
2. Add canary deployments
3. Enhance monitoring with custom metrics
4. Implement disaster recovery procedures
5. Add cost optimization automation
