#! /bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to show usage
usage() {
    echo -e "${BLUE}Linkerd Authorization Policy Demo Setup${NC}"
    echo ""
    echo "Usage: $0 [-s|-d]"
    echo "  -s     Setup and apply all resources"
    echo "  -d     Delete namespace and cleanup"
    exit 1
}

apply-policies() {
    echo -e "${BLUE}Applying policies...${NC}"
    echo -e "${BLUE}Probe route...${NC}"
    kubectl apply -f probe-route.yaml
    watch -n 1 "linkerd viz authz -n booksapp deploy/authors"
    echo -e "${BLUE}HTTP get route...${NC}"
    kubectl apply -f http-get-route.yaml
    watch -n 1 "linkerd viz authz -n booksapp deploy/authors"
    echo -e "${BLUE}HTTP modify route...${NC}"
    kubectl apply -f http-modify-route.yaml
    watch -n 1 "linkerd viz authz -n booksapp deploy/authors"
}

# Check if an argument is provided
if [ $# -eq 0 ]; then
    usage
fi

# Parse command line arguments
while getopts "sadfo" opt; do
    case ${opt} in
        s )
            # Setup resources
            echo -e "${BLUE}Setting up resources...${NC}"
            kubectl apply -f namespace.yaml
            kubectl apply -f app-authors.yaml
            kubectl apply -f app-books.yaml
            kubectl apply -f app-webapp.yaml
            kubectl apply -f app-traffic.yaml
            echo -e "${YELLOW}Waiting for all pods to be ready...${NC}"
            kubectl wait -n booksapp --for=condition=available deployment/authors deployment/books deployment/webapp --timeout=60s
            echo -e "${BLUE}Applying policies...${NC}"
            apply-policies
            ;;
        d )
            # Delete namespace
            echo -e "${BLUE}Deleting booksapp namespace...${NC}"
            kubectl delete namespace booksapp
            echo -e "${GREEN}✓ Booksapp namespace deleted successfully${NC}"
            ;;
        \? )
            usage
            ;;
    esac
done

exit 0