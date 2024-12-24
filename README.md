# E-Commerce Microservices Deployment

This repository contains the Kubernetes deployment configurations for the e-commerce microservices platform. The deployment uses Kustomize for environment-specific configurations.

## Architecture

The platform consists of the following components:

### Microservices
- **API Gateway** (`api-gateway-service`)
- **Products Service** (`products-service`) with MongoDB
- **Orders Service** (`orders-service`) with PostgreSQL
- **Users Service** (`users-service`) with PostgreSQL

### Databases
- **MongoDB** for Products Service (`products-db`)
- **PostgreSQL** for Orders Service (`orders-db`)
- **PostgreSQL** for Users Service (`users-db`)

## Directory Structure
```
k8s/
├── base/                   # Base configurations
│   └── kustomization.yaml
├── microservices/         # Microservice deployments
│   ├── api-gateway/
│   ├── products/
│   ├── orders/
│   └── users/
├── databases/             # Database StatefulSets
│   ├── mongodb/
│   └── postgresql/
├── hpa/                   # Horizontal Pod Autoscaling
└── overlays/             # Environment-specific configurations
    ├── development/
    ├── production/
    └── local/
```

## Configuration Management

### Base Configuration
The base configuration includes:
- Core service deployments
- Database StatefulSets
- Service configurations
- HPA settings
- Resource configurations via ConfigMaps

### Environment-Specific Configurations
Located in the `overlays` directory:

#### Development Environment
```bash
kubectl apply -k k8s/overlays/development
```
- Lower resource requirements for local development
- Single replicas
- Local image pulling (Never)
- Development-focused settings
- Database migration jobs for initial setup

#### Production Environment
```bash
kubectl apply -k k8s/overlays/production
```
- Higher resource limits
- Multiple replicas
- Remote image pulling (Always)
- Production-grade settings

## Resource Configurations

### Microservices
- **API Gateway**:
  - Development:
    - CPU: 25m request
    - Memory: 128Mi request
  - Production:
    - CPU: 100m-200m
    - Memory: 256Mi-512Mi
    - Replicas: 2-3

- **Products/Orders/Users Services**:
  - Development:
    - CPU: 25m request
    - Memory: 128Mi request
  - Production:
    - CPU: 100m-200m
    - Memory: 256Mi-512Mi
    - Replicas: 2-3

### Database Migrations
- Automated migration jobs for:
  - Users Service database
  - Orders Service database
- Jobs run automatically during deployment
- One-time execution per schema update

### Databases
- **MongoDB (Products)**:
  - CPU: 200m-500m
  - Memory: 256Mi-512Mi
  - Storage: 10Gi

- **PostgreSQL (Orders/Users)**:
  - CPU: 200m-500m
  - Memory: 256Mi-512Mi
  - Storage: 10Gi

## Security

- All sensitive data stored in Kubernetes Secrets
- Database credentials managed via secrets
- Services run with appropriate security contexts
- Network policies (TODO)

## Monitoring

- Prometheus annotations for metrics
- HPA configurations for auto-scaling
- Health check endpoints
- Resource monitoring

## Getting Started

1. **Prerequisites**:
   - Kubernetes cluster
   - kubectl installed
   - Kustomize installed (v4.x+)

2. **Local Development**:
   ```bash
   # Deploy local environment
   kubectl apply -k k8s/overlays/local
   
   # View resources
   kubectl get all -n ecommerce-local
   ```

3. **Production Deployment**:
   ```bash
   # Deploy production environment
   kubectl apply -k k8s/overlays/production
   
   # View resources
   kubectl get all -n ecommerce-prod
   ```

## Maintenance

### Updating Configurations
1. Modify base configurations in `k8s/base/`
2. Update environment-specific settings in `k8s/overlays/`
3. Apply changes using `kubectl apply -k`

### Scaling
- Services automatically scale based on HPA configurations
- Manual scaling available through kubectl
- Database scaling requires additional steps

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
