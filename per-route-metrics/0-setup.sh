#! /bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to show usage
usage() {
    echo -e "${BLUE}Linkerd Per-Route Metrics Demo Setup${NC}"
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
while getopts "sadfop" opt; do
    case ${opt} in
        s )
            echo -e "${BLUE}Setting up resources...${NC}"
            # Setup resources   
            kubectl apply -f namespace.yaml -n per-route-metrics
            kubectl apply -f app-authors.yaml -n per-route-metrics
            kubectl apply -f app-books.yaml -n per-route-metrics
            kubectl apply -f app-webapp.yaml -n per-route-metrics
            kubectl apply -f app-traffic.yaml -n per-route-metrics
            kubectl apply -f books-routes.yaml -n per-route-metrics
            echo -e "${YELLOW}Waiting for pods to be ready...${NC}"
            kubectl wait -n per-route-metrics --for=condition=ready pod -l project=booksapp --timeout=60s
            echo -e "${BLUE}Checking status...${NC}"
            watch -n 1 "linkerd viz -n per-route-metrics stat deploy"
            echo -e "${BLUE}Applying service profiles...${NC}"
            kubectl apply -f service-profiles.yaml -n per-route-metrics
            echo -e "${GREEN}Done${NC}"
            watch -n 1 "linkerd viz routes -n per-route-metrics deploy"
            ;;
        d )
            # Delete namespace
            echo -e "${BLUE}Deleting per-route-metrics namespace...${NC}"
            kubectl delete namespace per-route-metrics
            echo -e "${GREEN}✓ Per-route-metrics namespace deleted successfully${NC}"
            ;;
        \? )
            usage
            ;;
    esac
done

exit 0