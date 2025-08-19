#! /bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to show usage
usage() {
    echo -e "${BLUE}Linkerd Injecting Faults Demo Setup${NC}"
    echo ""
    echo "Usage: $0 [-s|-d]"
    echo "  -s     Setup and apply all resources"
    echo "  -d     Delete namespace and cleanup"
    exit 1
}

# Check if an argument is provided
if [ $# -eq 0 ]; then
    usage
fi

# Parse command line arguments
while getopts "sd" opt; do
    case ${opt} in
        s )
            # Setup resources   
            echo -e "${BLUE}Setting up resources...${NC}"
            kubectl create ns injecting-faults
            echo -e "${BLUE}Annotating namespace with linkerd.io/inject=enabled...${NC}"
            kubectl annotate namespace injecting-faults "linkerd.io/inject=enabled"
            echo -e "${BLUE}Applying booksapp...${NC}"
            kubectl apply -f booksapp.yml -n injecting-faults
            kubectl -n injecting-faults patch deploy authors \
                --type='json' \
                -p='[{"op":"remove", "path":"/spec/template/spec/containers/0/env/2"}]'
            echo -e "${YELLOW}Waiting for pods to be ready...${NC}"
            kubectl wait -n injecting-faults --for=condition=ready pod -l project=booksapp --timeout=60s
            echo -e "${BLUE}Checking status...${NC}"
            watch -n 1 "linkerd viz -n injecting-faults stat deploy"
            echo -e "${BLUE}Injecting faults...${NC}"
            kubectl apply -f faulty-backend.yaml -n injecting-faults
            echo -e "${YELLOW}Waiting for pods to be ready...${NC}"
            kubectl wait -n injecting-faults --for=condition=ready pod -l project=booksapp --timeout=60s
            echo -e "${BLUE}Checking status...${NC}"
            watch -n 1 "linkerd viz -n injecting-faults stat deploy"
            ;;
        d )
            # Delete namespace and cleanup
            echo -e "${BLUE}Deleting namespace and cleanup...${NC}"
            kubectl delete namespace injecting-faults
            echo -e "${GREEN}✓ Injecting-faults namespace deleted successfully${NC}"
            ;;
        \? )
            usage
            ;;
    esac
done