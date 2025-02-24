# AI Coding Bench - API Gateway Service

Central API Gateway service for managing and routing requests across the AI Coding Bench platform.

## Features
- Request routing
- Authentication & Authorization
- Rate limiting
- Request/Response transformation
- Service discovery
- Monitoring & logging

## Setup
1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Configure environment:
```bash
cp .env.example .env
# Edit .env with your configuration
```

## Development
- Python 3.8+
- FastAPI framework
- JWT authentication
- Redis for caching

## API Documentation
Swagger documentation available at `/docs` endpoint when running the service. 