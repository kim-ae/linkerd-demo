#! /bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to show usage
usage() {
    echo -e "${BLUE}Linkerd Rate Limit Demo Setup${NC}"
    echo ""
    echo "Usage: $0 [-x] [-d]"
    echo "  -x: Execute rate limit demo"
    echo "  -d: Delete emojivoto namespace"
    exit 1
}

init_demo(){
    echo -e "${BLUE}Initializing demo...${NC}"
    kubectl apply -f emojivoto.yml
    kubectl apply -f init.yaml
    echo -e "${YELLOW}Waiting to be ready...${NC}"
    sleep 30

    kubectl logs default-client -c http-client -f

    echo -e "${BLUE}Applying allowed client...${NC}"
    kubectl apply -f allowed-client.yaml
    
    echo -e "${YELLOW}Waiting to be ready...${NC}"
    sleep 30

    kubectl logs allowed-client -n emojivoto -c http-client -f
}

# Check if no arguments provided
if [ $# -eq 0 ]; then
    usage
fi

while getopts "xd" flag; do
  case "${flag}" in
    x)
      echo -e "${BLUE}Executing rate limit demo...${NC}"
      init_demo
      ;;
    d)
        echo -e "${BLUE}Deleting emojivoto namespace...${NC}"
        kubectl delete ns emojivoto
        kubectl delete pod default-client
        echo -e "${GREEN}✓ Emojivoto namespace and default-client pod deleted successfully${NC}"
      ;;
    *)
      usage
      ;;
  esac
done