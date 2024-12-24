# Local Setup Guide with Docker Desktop

## Step 1: Docker Desktop Setup

1. **Install Docker Desktop**
   - Download from [Docker Desktop](https://www.docker.com/products/docker-desktop)
   - Install with default settings
   - Start Docker Desktop

2. **Enable Kubernetes**
   - Open Docker Desktop
   - Click Settings (⚙️) > Kubernetes
   - Check "Enable Kubernetes"
   - Click "Apply & Restart"
   - Wait for Kubernetes to be "Running" (green)

## Step 2: Verify Installation

1. **Check Kubernetes**
   ```bash
   kubectl version
   kubectl cluster-info
   ```

2. **Verify Context**
   ```bash
   # Should show docker-desktop
   kubectl config current-context
   ```

## Step 3: Build Docker Images

1. **Build API Gateway**
   ```bash
   cd ../api-gateway
   docker build . -t ecommerce/api-gateway:latest
   ```

2. **Build Products Service**
   ```bash
   cd ../products-microservice
   docker build . -t ecommerce/products-service:latest
   ```

3. **Build Orders Service**
   ```bash
   cd ../orders-microservice
   docker build . -t ecommerce/orders-service:latest
   ```

4. **Build Users Service**
   ```bash
   cd ../users-microservice
   docker build . -t ecommerce/users-service:latest
   ```

5. **Verify Images**
   ```bash
   # For Windows PowerShell
   docker images | findstr "ecommerce"
   
   # Or simply list all images
   docker images
   ```

## Step 4: Create Namespaces

```bash
# Create development namespace
kubectl create namespace ecommerce-development

# Verify namespace
kubectl get namespaces | findstr ecommerce
```

## Step 5: Storage Setup

1. **Verify Storage Class**
   ```bash
   # Check default storage class
   kubectl get storageclass
   
   # Should see 'hostpath' or similar
   ```

## Step 6: Deploy Application

1. **Apply Kubernetes Configurations**
   ```bash
   # Apply development configurations
kubectl apply -k k8s/overlays/development -n ecommerce-development   ```

2. **Verify Deployments**
   ```bash
   # Watch pods starting up
   kubectl get pods -n ecommerce-development -w
   
   # Check services
   kubectl get services -n ecommerce-development
   
   # Check persistent volumes
   kubectl get pvc -n ecommerce-development
   ```

## Step 7: Verify Each Component

1. **Check API Gateway**
   ```bash
   # Port-forward API Gateway
   kubectl port-forward -n ecommerce-development svc/api-gateway 3000:3000
   
   # Test in browser: http://localhost:3000/health
   ```

2. **Check RabbitMQ**
   ```bash
   # Port-forward RabbitMQ Management
   kubectl port-forward -n ecommerce-development svc/rabbitmq 15672:15672
   
   # Access management UI: http://localhost:15672
   # Username: guest
   # Password: guest
   ```

3. **Check Database Services**
   ```bash
   # Check MongoDB
   kubectl port-forward -n ecommerce-development svc/mongodb 27017:27017
   
   # Check Users PostgreSQL
   kubectl port-forward -n ecommerce-development svc/users-postgres 5433:5433
   
   # Check Orders PostgreSQL
   kubectl port-forward -n ecommerce-development svc/orders-postgres 5432:5432
   ```

## Troubleshooting

### 1. Pods Not Starting
```bash
# Check pod details
kubectl describe pod <pod-name> -n ecommerce-development

# Check logs
kubectl logs <pod-name> -n ecommerce-development
```

### 2. Storage Issues
```bash
# Check PVC status
kubectl get pvc -n ecommerce-development

# Check PV status
kubectl get pv
```

### 3. Service Connection Issues
```bash
# Check endpoints
kubectl get endpoints -n ecommerce-development

# Check service details
kubectl describe service <service-name> -n ecommerce-development
```

### 4. Image Pull Issues
```bash
# Verify images exist locally
docker images

# Check pod events
kubectl describe pod <pod-name> -n ecommerce-development
```

## Clean Up

```bash
# Delete all resources in namespace
kubectl delete namespace ecommerce-development

# Or delete specific resources
kubectl delete -k k8s/overlays/development
```

## Useful Commands

```bash
# Get all resources in namespace
kubectl get all -n ecommerce-development

# Follow logs of a specific pod
kubectl logs -f <pod-name> -n ecommerce-development

# Execute command in pod
kubectl exec -it <pod-name> -n ecommerce-development -- /bin/sh

# Check resource usage
kubectl top pods -n ecommerce-development
```

## Production Deployment

### Building for Production

1. **Build and Tag Images**
   ```bash
   # API Gateway
   cd ../api-gateway
   docker build . -t your-username/ecommerce/api-gateway:v1.0.0
   
   # Products Service
   cd ../products-microservice
   docker build . -t your-username/ecommerce/products-service:v1.0.0
   
   # Orders Service
   cd ../orders-microservice
   docker build . -t your-username/ecommerce/orders-service:v1.0.0
   
   # Users Service
   cd ../users-microservice
   docker build . -t your-username/ecommerce/users-service:v1.0.0
   ```

2. **Push to Docker Hub**
   ```bash
   # Login to Docker Hub
   docker login
   
   # Push all images
   docker push your-username/ecommerce/api-gateway:v1.0.0
   docker push your-username/ecommerce/products-service:v1.0.0
   docker push your-username/ecommerce/orders-service:v1.0.0
   docker push your-username/ecommerce/users-service:v1.0.0
   ```

3. **Deploy to Production**
   ```bash
   kubectl apply -k k8s/overlays/production
   ```

### Image Naming Convention
- **Local Development**: `ecommerce/<service-name>:latest`
- **Production**: `your-username/ecommerce/<service-name>:v1.0.0`

This ensures:
- Clear separation between local and production images
- Proper versioning for production deployments
- Easy rollback capability with version tags
- Integration with CI/CD pipelines

## Next Steps

1. Set up monitoring with:
   - Prometheus for metrics
   - Grafana for visualization

2. Configure logging with:
   - ELK Stack or
   - Loki + Grafana

3. Set up development tools:
   - Kubernetes Dashboard
   - k9s for CLI management
