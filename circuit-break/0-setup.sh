#! /bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to show usage
usage() {
    echo -e "${BLUE}Linkerd Circuit Breaking Demo Setup${NC}"
    echo ""
    echo "Usage: $0 [-s|-c|-m|-d|-h]"
    echo "  -s     Setup and apply circuit breaking demo resources"
    echo "  -c     Monitor circuit breaker in action (watch mode)"
    echo "  -m     Show manual monitoring commands"
    echo "  -d     Delete demo resources"
    echo "  -h     Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -s -a -c    # Complete setup and monitoring"
    echo "  $0 -s          # Setup resources only"
    echo "  $0 -m          # Show monitoring commands"
    exit 1
}

# Function to setup resources
setup_resources() {
    echo -e "${BLUE}Setting up circuit breaking demo resources...${NC}"
    
    if kubectl apply -f circuit-breaking-demo.yaml; then
        echo -e "${GREEN}✓ Demo resources deployed successfully${NC}"
        echo -e "${YELLOW}Waiting for pods to be ready...${NC}"
        kubectl wait --for=condition=ready pod -l app=bb -n circuit-breaking-demo --timeout=60s
        kubectl wait --for=condition=ready pod -l app=slow-cooker -n circuit-breaking-demo --timeout=60s
        echo -e "${GREEN}✓ All pods are ready${NC}"
    else
        echo -e "${RED}✗ Failed to deploy demo resources${NC}"
        exit 1
    fi
}

# Function to add circuit breaking annotation
add_circuit_breaking() {
    echo -e "${BLUE}Adding circuit breaking annotation...${NC}"
    
    if kubectl annotate svc/bb -n circuit-breaking-demo balancer.linkerd.io/failure-accrual=consecutive; then
        echo -e "${GREEN}✓ Circuit breaking annotation added${NC}"
        echo -e "${YELLOW}Circuit breaker will trigger after 5 consecutive failures${NC}"
    else
        echo -e "${RED}✗ Failed to add circuit breaking annotation${NC}"
        exit 1
    fi
}

# Function to monitor circuit breaker
monitor_circuit_breaker() {
    echo -e "${BLUE}Starting circuit breaker monitoring...${NC}"
    echo -e "${YELLOW}Press Ctrl+C to stop monitoring${NC}"
    echo ""
    watch -n 1 linkerd viz stat -n circuit-breaking-demo deploy
}

# Function to delete resources
delete_resources() {
    echo -e "${BLUE}Deleting circuit breaking demo resources...${NC}"
    
    if kubectl delete namespace circuit-breaking-demo; then
        echo -e "${GREEN}✓ Demo resources deleted successfully${NC}"
    else
        echo -e "${RED}✗ Failed to delete demo resources${NC}"
        exit 1
    fi
}

# Check if an argument is provided
if [ $# -eq 0 ]; then
    usage
fi

# Parse command line arguments
while getopts "scmdh" opt; do
    case ${opt} in
        s )
            check_prerequisites
            setup_resources
            monitor_circuit_breaker
            add_circuit_breaking
            monitor_circuit_breaker
            ;;
        c) 
            monitor_circuit_breaker
            ;;
        m )
            show_monitoring
            ;;
        d )
            delete_resources
            ;;
        h )
            usage
            ;;
        \? )
            usage
            ;;
    esac
done

exit 0
