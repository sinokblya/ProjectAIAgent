# EdAgent AI - Complete Installation & Deployment Guide

## 📋 Table of Contents
1. [Quick Start (Local)](#quick-start-local)
2. [Docker Deployment](#docker-deployment)
3. [Kubernetes Deployment](#kubernetes-deployment)
4. [Cloud Deployment (AWS/Azure/GCP)](#cloud-deployment)
5. [Configuration](#configuration)
6. [API Documentation](#api-documentation)
7. [Troubleshooting](#troubleshooting)

---

## 🚀 Quick Start (Local)

### Prerequisites
- Python 3.11+
- PostgreSQL 15
- Redis 7
- Node.js 18 (optional, for frontend build)

### Installation

1. **Clone repository**
```bash
git clone https://github.com/yourname/edagent.git
cd edagent
```

2. **Setup Python environment**
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. **Install dependencies**
```bash
cd backend
pip install -r requirements.txt
python -m spacy download ru_core_news_sm
```

4. **Setup database**
```bash
# Create PostgreSQL database
createdb edagent_db -U postgres

# Run migrations (if using Alembic)
alembic upgrade head
```

5. **Configure environment**
```bash
cp .env.example .env
# Edit .env with your API keys and configuration
```

6. **Run backend**
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

7. **Open frontend**
```bash
# Open browser to http://localhost:8000
```

---

## 🐳 Docker Deployment

### One-Command Startup

```bash
docker-compose up -d
```

This starts:
- PostgreSQL (port 5432)
- Redis (port 6379)
- FastAPI Backend (port 8000)
- Nginx Frontend (port 80)
- Celery Workers
- Prometheus Monitoring (port 9090)
- Grafana Dashboard (port 3000)

### View logs
```bash
docker-compose logs -f backend
docker-compose logs -f frontend
```

### Stop services
```bash
docker-compose down
docker-compose down -v  # Also remove volumes
```

### Rebuild containers
```bash
docker-compose build --no-cache
docker-compose up -d
```

---

## ☸️ Kubernetes Deployment

### Prerequisites
- Kubernetes cluster (1.24+)
- kubectl configured
- Helm 3+

### Deploy to Kubernetes

1. **Create namespace**
```bash
kubectl create namespace edagent
```

2. **Create secrets**
```bash
kubectl create secret generic edagent-secrets \
  --from-literal=db-password=your-db-password \
  --from-literal=openai-key=your-openai-key \
  --from-literal=sendgrid-key=your-sendgrid-key \
  -n edagent
```

3. **Deploy PostgreSQL**
```bash
kubectl apply -f kubernetes/postgres-deployment.yaml -n edagent
```

4. **Deploy Redis**
```bash
kubectl apply -f kubernetes/redis-deployment.yaml -n edagent
```

5. **Deploy Backend**
```bash
kubectl apply -f kubernetes/backend-deployment.yaml -n edagent
kubectl apply -f kubernetes/backend-service.yaml -n edagent
```

6. **Deploy Frontend**
```bash
kubectl apply -f kubernetes/frontend-deployment.yaml -n edagent
kubectl apply -f kubernetes/frontend-service.yaml -n edagent
```

7. **Check deployment**
```bash
kubectl get pods -n edagent
kubectl get svc -n edagent
```

8. **Access application**
```bash
# Get LoadBalancer IP
kubectl get svc frontend -n edagent
# Open http://<external-ip>
```

### Scaling

```bash
# Scale backend to 3 replicas
kubectl scale deployment backend --replicas=3 -n edagent

# Auto-scaling with HPA
kubectl apply -f kubernetes/hpa.yaml -n edagent
```

---

## ☁️ Cloud Deployment

### AWS (EKS)

```bash
# Create EKS cluster
aws eks create-cluster --name edagent --region eu-central-1

# Get credentials
aws eks update-kubeconfig --region eu-central-1 --name edagent

# Deploy
kubectl apply -f kubernetes/

# Create LoadBalancer
aws elb create-load-balancer --load-balancer-name edagent-lb \
  --listeners InstancePort=80,LoadBalancerPort=80,Protocol=HTTP
```

### Azure (AKS)

```bash
# Create resource group
az group create --name edagent-rg --location westeurope

# Create AKS cluster
az aks create --resource-group edagent-rg --name edagent-aks \
  --node-count 3 --vm-set-type VirtualMachineScaleSets

# Get credentials
az aks get-credentials --resource-group edagent-rg --name edagent-aks

# Deploy
kubectl apply -f kubernetes/
```

### GCP (GKE)

```bash
# Create GKE cluster
gcloud container clusters create edagent-cluster \
  --num-nodes 3 --region europe-west1

# Get credentials
gcloud container clusters get-credentials edagent-cluster --region europe-west1

# Deploy
kubectl apply -f kubernetes/

# Expose service
kubectl expose deployment frontend --name edagent-lb \
  --type LoadBalancer --port 80
```

---

## ⚙️ Configuration

### Environment Variables

Key variables in `.env`:

```bash
# Database
DATABASE_URL=postgresql://user:password@host:5432/edagent

# Redis
REDIS_URL=redis://host:6379

# API Keys
OPENAI_API_KEY=sk-...
SENDGRID_API_KEY=SG....

# Settings
DEBUG=false
LOG_LEVEL=INFO
ENVIRONMENT=production
```

### Database Configuration

```bash
# Connect to PostgreSQL
psql -h localhost -U edagent_user -d edagent_db

# Create tables
\d

# Backup database
pg_dump edagent_db > backup.sql

# Restore database
psql edagent_db < backup.sql
```

### Redis Configuration

```bash
# Connect to Redis
redis-cli -h localhost -p 6379

# Check memory usage
info memory

# Clear cache
flushall

# Monitor operations
monitor
```

---

## 📚 API Documentation

### Interactive Docs

- Swagger UI: http://localhost:8000/api/docs
- ReDoc: http://localhost:8000/api/redoc
- OpenAPI JSON: http://localhost:8000/openapi.json

### Key Endpoints

**Phase 1: Vacancy Analysis**
```bash
GET /api/vacancies/analyze?industry=IT%20Services
```

**Phase 2: Company Search**
```bash
GET /api/companies/search?industry=IT%20Services&limit=100
```

**Phase 3: Communication Generation**
```bash
POST /api/communications/generate
Content-Type: application/json

{
  "company_id": "company_1",
  "company_name": "Yandex",
  "recipient": "VP of Technology",
  "email": "vp@yandex.ru",
  "tech_stack": "Python, Go, Kubernetes",
  "style": "formal"
}
```

**Send Communication**
```bash
POST /api/communications/send
Content-Type: application/json

{
  "email": "vp@yandex.ru",
  "company_name": "Yandex",
  "recipient": "VP of Technology",
  "letter": "..."
}
```

**Analytics Dashboard**
```bash
GET /api/analytics/dashboard
```

---

## 🔧 Troubleshooting

### Database Connection Issues

```bash
# Test PostgreSQL connection
psql -h localhost -U edagent_user -d edagent_db -c "SELECT 1"

# Check PostgreSQL logs
docker logs edagent-postgres

# Restart PostgreSQL
docker restart edagent-postgres
```

### Redis Connection Issues

```bash
# Test Redis connection
redis-cli ping

# Check Redis logs
docker logs edagent-redis

# Restart Redis
docker restart edagent-redis
```

### Backend Issues

```bash
# Check backend logs
docker logs -f edagent-backend

# Test API
curl http://localhost:8000/api/health

# Restart backend
docker restart edagent-backend
```

### Frontend Issues

```bash
# Check Nginx logs
docker logs edagent-frontend

# Test Nginx
curl http://localhost

# Restart frontend
docker restart edagent-frontend
```

### Performance Issues

```bash
# Monitor resource usage
docker stats

# Check database connections
psql -c "SELECT count(*) FROM pg_stat_activity;"

# Monitor Redis memory
redis-cli info memory

# Scale up
docker-compose up -d --scale backend=3
```

---

## 📊 Monitoring & Logging

### Prometheus Metrics
- Access: http://localhost:9090

### Grafana Dashboard
- Access: http://localhost:3000
- Default credentials: admin/admin

### View Logs

```bash
# Backend logs
docker-compose logs backend

# Database logs
docker-compose logs postgres

# All services
docker-compose logs

# Follow logs
docker-compose logs -f
```

---

## 🔐 Security Considerations

1. **Environment Variables**
   - Never commit `.env` to version control
   - Rotate API keys regularly
   - Use secrets management (AWS Secrets Manager, Azure Key Vault, etc.)

2. **Database**
   - Enable SSL connections
   - Use strong passwords
   - Regular backups
   - Row-level security

3. **API Security**
   - Enable HTTPS/TLS
   - Implement rate limiting
   - Use API authentication
   - Validate all inputs

4. **Container Security**
   - Scan images for vulnerabilities
   - Use non-root user in containers
   - Keep dependencies updated
   - Use private registries

---

## 📈 Performance Optimization

### Caching Strategy
- L1: Redis (hot data)
- L2: PostgreSQL (persistent)
- L3: Full refresh (daily)

### Database Optimization
```bash
# Create indexes
CREATE INDEX idx_company_score ON companies(scoring DESC);
CREATE INDEX idx_vacancy_competencies ON vacancies USING GIN(competencies);

# Analyze query performance
EXPLAIN ANALYZE SELECT * FROM companies WHERE scoring > 80;
```

### Load Testing

```bash
# Using Apache Bench
ab -n 1000 -c 10 http://localhost:8000/api/health

# Using wrk
wrk -t4 -c100 -d30s http://localhost:8000/api/health
```

---

## 📞 Support & Resources

- GitHub Issues: https://github.com/yourname/edagent/issues
- Documentation: https://edagent-docs.example.com
- Community Forum: https://community.edagent.ai
- Email: support@edagent.ai

---

## 📝 License

MIT License - see LICENSE file for details

---

**Last Updated**: December 2024
**Version**: 1.0.0
