# AI Coding Bench Improved

A comprehensive AI-powered coding platform organized as a monorepo.

## Repository Structure

```
ai_coding_bench_improved/
├── services/
│   ├── pdf-analyzer/      # PDF analysis service
│   ├── api-gateway/       # API Gateway service
│   └── common/            # Shared utilities
├── docs/                  # Documentation
├── scripts/               # Maintenance scripts
└── tools/                 # Development tools
```

## Getting Started

1. Clone the repository with submodules:
```bash
git clone --recursive https://github.com/your-org/ai-coding-bench-improved.git
cd ai-coding-bench-improved
```

2. Run the setup script:
```bash
./scripts/setup_monorepo.sh
```

3. Set up development environment:
```bash
./tools/development/setup_dev_env.sh
```

## Development

Each service has its own virtual environment and dependencies. To work on a specific service:

1. Navigate to the service directory:
```bash
cd services/<service-name>
```

2. Activate the virtual environment:
```bash
source venv/bin/activate
```

3. Start developing!

## Documentation

- [Architecture](docs/ARCHITECTURE.md)
- [Contributing Guidelines](docs/CONTRIBUTING.md)
- [Technical Requirements](docs/TECHNICAL_REQUIREMENTS.md)
- [Roadmap](docs/ROADMAP.md)

## License

MIT License - see LICENSE file for details