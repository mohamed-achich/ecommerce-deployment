# Production Secrets Management

This directory contains the secret templates for the production environment. The actual secret values should **never** be committed to the repository.

## Secret Management Options

1. **Environment Variables**: 
   - Create a `.env` file locally (add to .gitignore)
   - Use `envsubst` or similar tool to replace placeholders before applying

2. **External Secret Management**:
   - Use Azure Key Vault with Azure Key Vault Provider for Secrets Store CSI Driver
   - Use HashiCorp Vault with External Secrets Operator
   - Use AWS Secrets Manager with External Secrets Operator

## How to Apply Secrets

1. Copy the secret template files
2. Fill in the secret values using one of these methods:
   - Manual replacement
   - Environment variable substitution
   - Secret management tool

Example using environment variables:
```bash
# Create a .env file with your secrets
cat > .env << EOF
JWT_SECRET=your-secure-jwt-secret
REDIS_PASSWORD=your-redis-password
MONGODB_URI=mongodb://username:password@host:port/database
POSTGRES_PASSWORD=your-postgres-password
DATABASE_URL=postgresql://username:password@host:port/database
EOF

# Apply secrets using envsubst
for file in *.yaml; do
  envsubst < $file | kubectl apply -f -
done
```

## Security Notes

- Never commit actual secret values to the repository
- Use strong, unique passwords for each service
- Rotate secrets regularly
- Use proper RBAC to restrict access to secrets
- Consider using sealed secrets for GitOps workflows
