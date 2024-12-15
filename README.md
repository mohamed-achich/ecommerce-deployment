# E-commerce Microservices System

A secure, scalable e-commerce system built with microservices architecture.

## System Architecture

```mermaid
graph TB
    Client[Client Applications]
    
    subgraph API_Gateway[API Gateway - NestJS]
        Router[Request Router]
        RateLimit[Rate Limiter]
        Auth[Auth Middleware]
    end
    
    subgraph Users_Service[Users Service]
        Users_API[REST API]
        Users_GRPC[gRPC Server]
        Users_DB[(PostgreSQL)]
    end
    
    subgraph Products_Service[Products Service]
        Products_API[REST API]
        Products_GRPC[gRPC Server]
        Products_DB[(MongoDB)]
    end
    
    subgraph Orders_Service[Orders Service]
        Orders_API[REST API]
        Orders_GRPC[gRPC Server]
        Orders_DB[(PostgreSQL)]
    end
    
    subgraph Message_Broker[Message Broker]
        RabbitMQ[RabbitMQ]
    end
    
    subgraph Cache[Cache Layer]
        Redis[Redis]
    end
    
    Client --> API_Gateway
    API_Gateway --> Users_Service
    API_Gateway --> Products_Service
    API_Gateway --> Orders_Service
    
    Users_Service --> Users_DB
    Products_Service --> Products_DB
    Orders_Service --> Orders_DB
    
    Orders_Service --> Message_Broker
    Products_Service --> Message_Broker
    
    API_Gateway --> Cache
    Users_Service --> Cache
```

## Component Details

### API Gateway (Port: 3000)
- Request routing and load balancing
- Rate limiting with Redis
- Authentication middleware
- CORS and security headers
- Request validation
- Error handling

### Users Service (Ports: 5002, 5052)
- User management and authentication
- JWT token generation and validation
- Role-based access control
- PostgreSQL for user data
- gRPC server for inter-service auth

### Products Service (Ports: 5000, 5050)
- Product catalog management
- Inventory tracking
- MongoDB for product data
- gRPC server for product validation
- RabbitMQ integration for inventory updates

### Orders Service (Ports: 5001, 5051)
- Order processing
- Payment integration
- PostgreSQL for order data
- gRPC server for order validation
- RabbitMQ integration for order events

### Shared Infrastructure
- Redis: Session management, rate limiting, token blacklisting
  - Redis Commander UI (Port: 8081) for data visualization
- RabbitMQ: Event messaging, async operations
- PostgreSQL: Users and Orders data
- MongoDB: Products catalog
- Docker & Docker Compose: Container orchestration

## Development Tools

### Redis Commander
- Web-based Redis management interface
- Available at http://localhost:8081
- Features:
  - View all Redis keys and data
  - Monitor session management
  - Track rate limiting
  - Manage token blacklist
  - Real-time data updates

### Database Management
- MongoDB: MongoDB Compass or Studio 3T
- PostgreSQL: pgAdmin or DBeaver
- Redis: Redis Commander

## Communication Patterns

### Synchronous Communication
- REST APIs: Client-Gateway communication
- gRPC: Inter-service communication
- Service Authentication: JWT-based

### Asynchronous Communication
- RabbitMQ Events:
  - Order Created
  - Order Status Updated
  - Product Stock Updated
  - User Events

## Architecture Overview

The system consists of four main components:
- API Gateway (NestJS) - Routes and rate limiting
- Users Service (NestJS + PostgreSQL) - User management and authentication
- Products Service (NestJS + MongoDB) - Product catalog and inventory
- Orders Service (NestJS + PostgreSQL) - Order processing and management

## Security Features

### 1. Authentication & Authorization
- Centralized authentication via Users Service
- JWT-based authentication
  - Access tokens (15 minutes lifetime)
  - Refresh tokens (7 days lifetime)
  - Token blacklisting for revocation
- Role-based access control (RBAC)
- Refresh token mechanism
- Token blacklisting
- Service-to-service authentication

### 2. Rate Limiting
- IP-based rate limiting
- Endpoint-specific limits
- Redis-based implementation

### 3. Session Management
- Redis-based session storage
  - Access token tracking
  - Refresh token management
  - Token blacklisting for logout
  - Rate limiting counters
- Secure session handling
- Session expiration
- Concurrent session control

### 4. Inter-Service Communication
- gRPC with TLS (Transport Layer Security)
- Service authentication tokens
- Message queue security (RabbitMQ)

### 5. Data Security
- Password hashing (bcrypt)
- Environment variable protection
- Secure headers
- CORS protection

## API Routes

### Public Routes (No Authentication Required)
- POST /auth/register - Register new user
- POST /auth/login - User login
- GET /products - List all products
- GET /products/:id - Get product details

### Protected Routes (Authentication Required)
#### User Routes
- POST /auth/logout - User logout
- POST /auth/refresh - Refresh access token
- GET /users/me - Get current user profile
- PUT /users/me - Update user profile

#### Order Routes
- POST /orders - Create new order
- GET /orders - List user's orders
- GET /orders/:id - Get order details

#### Admin Routes (Admin Role Required)
- POST /products - Create product
- PUT /products/:id - Update product
- DELETE /products/:id - Delete product
- GET /users - List all users
- GET /orders/all - List all orders

## Setup Instructions

### Prerequisites
- Docker and Docker Compose
- Node.js (for development)
- Redis
- MongoDB
- PostgreSQL
- RabbitMQ

### Environment Setup

1. Create `.env` files in each service directory using the provided `.env.example` files
2. Generate secure secrets for JWT tokens:
```bash
# Run these commands to generate secure secrets
openssl rand -base64 32 # For JWT_SERVICE_SECRET
openssl rand -base64 32 # For JWT_REFRESH_SECRET
openssl rand -base64 32 # For JWT_SERVICE_SECRET
```

### Development Setup

1. Clone all repositories:
```bash
git clone https://github.com/your-username/api-gateway
git clone https://github.com/your-username/users-microservice
git clone https://github.com/your-username/products-microservice
git clone https://github.com/your-username/orders-microservice
git clone https://github.com/your-username/ecommerce-deployment
```

2. Start the entire system:
```bash
cd ecommerce-deployment
docker-compose up
```

### Production Deployment Guidelines

1. **Environment Variables**
   - Use secure secrets management (e.g., Kubernetes Secrets)
   - Rotate secrets regularly
   - Never commit .env files

2. **Network Security**
   - Use private networks for inter-service communication
   - Implement network policies
   - Enable TLS for all communications

3. **Monitoring & Logging**
   - Implement centralized logging
   - Set up monitoring for security events
   - Enable audit logging

4. **Container Security**
   - Use minimal base images
   - Scan containers for vulnerabilities
   - Implement resource limits

## Security Best Practices

### API Gateway
- Validate all incoming requests
- Implement request size limits
- Use secure headers (helmet)
- Enable rate limiting
- Implement CORS properly

### Authentication Endpoints

1. Register a new user:
```http
POST http://localhost:3000/auth/register
Content-Type: application/json

{
    "email": "your-email@example.com",
    "password": "your-password",
    "name": "Your Name"
}
```

2. Login:
```http
POST http://localhost:3000/auth/login
Content-Type: application/json

{
    "email": "your-email@example.com",
    "password": "your-password"
}
```

3. Refresh Token:
```http
POST http://localhost:3000/auth/refresh
Content-Type: application/json

{
    "refreshToken": "your-refresh-token-here"
}
```

4. Get User Profile:
```http
GET http://localhost:3000/auth/me
Authorization: Bearer your-jwt-token-here
```

### Microservices
- Use service authentication
- Validate all inter-service communications
- Implement circuit breakers
- Use secure configurations

### Database Security
- Use strong passwords
- Enable authentication
- Implement connection pooling
- Regular backups
- Encryption at rest

### Message Queue Security
- Enable authentication
- Use SSL/TLS
- Implement message encryption
- Set proper permissions

## Monitoring & Maintenance

### Health Checks
- API Gateway: http://localhost:3000/health
- Users Service: http://localhost:5000/health
- Products Service: http://localhost:5001/health
- Orders Service: http://localhost:5002/health

### Logging
- Centralized logging with ELK stack
- Security event logging
- Audit trails

### Metrics
- Prometheus metrics
- Grafana dashboards
- Rate limiting metrics
- Security event metrics

## Contributing

Please read our security guidelines before contributing:
1. Never commit sensitive information
2. Always use environment variables for secrets
3. Follow secure coding practices
4. Run security checks before commits

## License

MIT License

## E-commerce Microservices Deployment

## Authentication Flow

### Service Responsibilities

#### Users Microservice
- User data management (CRUD operations)
- Password hashing and storage
- Credential validation
- User registration logic
- Exposes gRPC endpoints for user operations

#### API Gateway
- JWT token generation and validation
- Session management with Redis
- Token refresh handling
- Route protection and access control
- Client authentication endpoints

### Authentication Process
1. Client Authentication:
   ```mermaid
   sequenceDiagram
      Client->>API Gateway: Login Request
      API Gateway->>Users Service: Validate Credentials (gRPC)
      Users Service->>Users Service: Verify Password
      Users Service->>API Gateway: Validation Result
      API Gateway->>Redis: Store Session & Refresh Token
      API Gateway->>Client: Return JWT Tokens
   ```

2. Token Refresh:
   ```mermaid
   sequenceDiagram
      Client->>API Gateway: Refresh Token Request
      API Gateway->>Redis: Validate Refresh Token
      API Gateway->>Users Service: Get User Data (gRPC)
      API Gateway->>Redis: Store New Session
      API Gateway->>Client: New JWT Tokens
   ```

### Data Flow
- Users Microservice:
  - Stores: User data, password hashes
  - Handles: Registration, password validation
  - Uses: PostgreSQL

- API Gateway:
  - Stores: Sessions, refresh tokens
  - Handles: JWT operations, authentication flow
  - Uses: Redis

### Security Implementation
1. Password Security (Users Microservice):
   - Scrypt for password hashing
   - Secure password validation
   - User data protection

2. Token Security (API Gateway):
   - JWT for stateless authentication
   - Redis for session management
   - Refresh token rotation
   - Access token short lifetime

### Environment Setup
```env
# Users Microservice
DATABASE_URL=postgresql://user:password@localhost:5432/users
GRPC_PORT=5000

# API Gateway
REDIS_HOST=localhost
REDIS_PORT=6379
JWT_SERVICE_SECRET=your-secret-key
JWT_EXPIRATION=15m
JWT_REFRESH_SECRET=your-refresh-secret
JWT_REFRESH_EXPIRATION=7d
```

### Deployment Steps
1. Start Redis for API Gateway
2. Start PostgreSQL for Users Service
3. Deploy Users Microservice
4. Deploy API Gateway
5. Configure network policies

### Security Considerations
- All passwords are hashed only in Users Microservice
- Tokens are managed exclusively by API Gateway
- Redis provides fast token validation
- Service communication is via gRPC only
