#! /bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to show usage
usage() {
    echo -e "${BLUE}Linkerd Dynamic Routing Demo Setup${NC}"
    echo ""
    echo "Usage: $0 [-s] [-d]"
    echo "  -s: Setup and execute dynamic routing demo"
    echo "  -d: Delete dynamic-routing namespace"
    exit 1
}

execute_requests(){
  echo -e "${BLUE}Executing requests from frontend...${NC}"
  kubectl -n test port-forward svc/frontend-podinfo 9898 & 
  PF_PID=$!
  watch -n 1 'if [ $((RANDOM % 2)) -eq 0 ]; then \
    curl -sX POST -H "x-request-id: alternative" localhost:9898/echo; \
    else curl -sX POST localhost:9898/echo; \
    fi | grep -o "PODINFO_UI_MESSAGE=. backend"'
  kill $PF_PID
}

# Check if no arguments provided
if [ $# -eq 0 ]; then
    usage
fi

while getopts "sd" opt; do
  case $opt in
    s)
      echo -e "${BLUE}Setting up dynamic routing demo...${NC}"
      kubectl create ns dynamic-routing --dry-run=client -o yaml \
        | linkerd inject - \
        | kubectl apply -f -
      helm repo add podinfo https://stefanprodan.github.io/podinfo
      helm install backend-a -n dynamic-routing \
        --set ui.message='A backend' podinfo/podinfo
      helm install backend-b -n dynamic-routing \
        --set ui.message='B backend' podinfo/podinfo
      helm install frontend -n test \
        --set backend=http://backend-a-podinfo:9898/env podinfo/podinfo
      echo -e "${YELLOW}Waiting for podinfo deployments to be ready...${NC}"
      kubectl wait -n dynamic-routing --for=condition=available deployment/backend-a-podinfo deployment/backend-b-podinfo --timeout=60s
      kubectl wait -n dynamic-routing --for=condition=available deployment/backend-a-podinfo deployment/backend-a-podinfo --timeout=60s
      kubectl wait -n test --for=condition=available deployment/frontend-podinfo --timeout=60s
      execute_requests
      echo -e "${BLUE}Deploying dynamic routing based on x-request-id header${NC}"
      kubectl apply -f httproute.yaml
      execute_requests
      ;;
    d)
      echo -e "${BLUE}Deleting dynamic-routing namespace...${NC}"
      kubectl delete ns dynamic-routing
      echo -e "${GREEN}✓ Dynamic-routing namespace deleted successfully${NC}"
      ;;
    *)
      usage
      ;;
  esac
done