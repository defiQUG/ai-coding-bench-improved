#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Setting up AI Coding Bench Improved monorepo...${NC}"

# Create necessary directories
mkdir -p services/pdf-analyzer services/api-gateway services/common tools/development

# Initialize git if not already initialized
if [ ! -d .git ]; then
    git init
    echo -e "${GREEN}Initialized git repository${NC}"
fi

# Initialize and update submodules
git submodule init
git submodule update --recursive --remote

# Move existing files to appropriate locations
if [ -f comprehensive_pdf_analyzer.py ]; then
    mv comprehensive_pdf_analyzer.py services/pdf-analyzer/
fi

if [ -f endpoints.py ]; then
    mv endpoints.py services/api-gateway/
fi

# Create docs directory and move documentation
mkdir -p docs
for file in *.md; do
    if [ -f "$file" ]; then
        mv "$file" docs/
    fi
done

# Set up development environment
echo -e "${BLUE}Setting up development environment...${NC}"
# Add any development environment setup here (e.g., virtual environment, dependencies)

echo -e "${GREEN}Monorepo setup complete!${NC}"
echo -e "${BLUE}Next steps:${NC}"
echo "1. Fork the following repositories to your organization:"
echo "   - ai-coding-bench-pdf-analyzer"
echo "   - ai-coding-bench-api-gateway"
echo "   - ai-coding-bench-common"
echo "2. Update .gitmodules with your organization's repository URLs"
echo "3. Run 'git submodule update --init --recursive'" 