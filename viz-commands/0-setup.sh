#! /bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color


# Function to show monitoring commands
show_monitoring() {
    echo -e "${BLUE}Linkerd CLI: Monitoring Commands${NC}"
    echo "for more info: https://linkerd.io/2.12/reference/cli/viz/"
    echo -e "${GREEN}View deployment metrics:${NC}"
    echo "  linkerd viz stat -n viz-commands deploy/pod/svc"
    echo ""
    echo -e "${GREEN}Check circuit breaker edges:${NC}"
    echo "  linkerd viz edges -n viz-commands deploy/pod/svc"
    echo ""
    echo -e "${GREEN}Dashboard:${NC}"
    echo "  linkerd viz dashboard"
    echo ""
    echo -e "${GREEN}Check pods that can be tapped:${NC}"
    echo "  linkerd viz list -n viz-commands"
    echo ""
    echo -e "${GREEN}Tap all deployments:${NC}"
    echo "  linkerd viz tap -n viz-commands deploy"
    echo ""
    echo -e "${GREEN}Display live traffic:${NC}"
    echo "  linkerd viz top -n viz-commands deploy"
    echo ""
}


# Function to show usage
usage() {
    echo -e "${BLUE}Linkerd CLI: Monitoring Commands${NC}"
    echo ""
    echo "Usage: $0 [-s|-t|-d]"
    echo "  -s     Setup and apply all resources"
    echo "  -t     Display commands"
    echo "  -d     Delete namespace and cleanup"
    exit 1
}

# Check if an argument is provided
if [ $# -eq 0 ]; then
    usage
fi

# Parse command line arguments
while getopts "sdt" opt; do
    case ${opt} in
        s )
            echo -e "${BLUE}Setting up resources...${NC}"
            kubectl create ns viz-commands
            echo -e "${BLUE}Annotating namespace with linkerd.io/inject=enabled...${NC}"
            kubectl annotate namespace viz-commands "linkerd.io/inject=enabled"
            echo -e "${BLUE}Applying booksapp...${NC}"
            kubectl apply -f booksapp.yml -n viz-commands
            echo -e "${BLUE}View deployment metrics with deployment lens:${NC}"
            watch -n 1 "linkerd viz stat -n viz-commands deploy"
            echo -e "${BLUE}Check circuit breaker edges:${NC}"
            watch -n 1 "linkerd viz edges -n viz-commands deploy"
            ;;
        d )
            # Delete namespace and cleanup
            echo -e "${BLUE}Deleting namespace and cleanup...${NC}"
            kubectl delete namespace viz-commands
            echo -e "${GREEN}✓ Viz-commands namespace deleted successfully${NC}"
            ;;
        t )
            show_monitoring
            ;;
        \? )
            usage
            ;;
    esac
done