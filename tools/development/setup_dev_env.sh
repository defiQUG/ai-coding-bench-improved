#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Setting up development environment...${NC}"

# Check Python version
python_version=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
if (( $(echo "$python_version 3.8" | awk '{print ($1 < $2)}') )); then
    echo -e "${RED}Error: Python 3.8 or higher is required${NC}"
    exit 1
fi

# Create virtual environments for each service
services=("pdf-analyzer" "api-gateway")
for service in "${services[@]}"; do
    echo -e "${BLUE}Setting up environment for $service...${NC}"
    cd "services/$service" || exit
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    deactivate
    cd ../..
done

# Set up common utilities
echo -e "${BLUE}Setting up common utilities...${NC}"
cd services/common || exit
python3 -m venv venv
source venv/bin/activate
pip install -e ".[dev]"
deactivate
cd ../..

echo -e "${GREEN}Development environment setup complete!${NC}"
echo -e "${BLUE}Next steps:${NC}"
echo "1. Activate the virtual environment for your service:"
echo "   cd services/<service-name> && source venv/bin/activate"
echo "2. Start developing!" 