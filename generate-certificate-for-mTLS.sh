#!/bin/bash

# Remove the .linkerd-certs directory if it exists and recreate it
if [ -d ".linkerd-certs" ]; then
  rm -rf .linkerd-certs
fi
mkdir -p .linkerd-certs

# Check if step is installed
if ! command -v step &> /dev/null; then
  echo "Error: step CLI is not installed. Please install it and try again."
  exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
  echo "Error: kubectl is not installed. Please install it and try again."
  exit 1
fi

# Check if kubeseal is installed
if ! command -v kubeseal &> /dev/null; then
  echo "Error: kubeseal is not installed. Please install it and try again."
  exit 1
fi

# Check if kubectl context is loaded
if ! kubectl config current-context &> /dev/null; then
  echo "Error: No kubectl context is loaded. Please configure your kubectl context and try again."
  exit 1
fi

# Inform the user and ask if they want to continue
echo "Kubectl context is loaded: $(kubectl config current-context)"
read -p "Do you want to continue? (yes/no): " user_input
if [[ "$user_input" != "yes" ]]; then
  echo "Operation aborted by the user."
  exit 1
fi

# Generate the trust anchor certificate
step certificate create root.linkerd.cluster.local .linkerd-certs/ca.crt .linkerd-certs/ca.key \
  --profile root-ca --no-password --insecure

# Generate the issuer certificate
step certificate create identity.linkerd.cluster.local .linkerd-certs/issuer.crt .linkerd-certs/issuer.key \
  --ca .linkerd-certs/ca.crt --ca-key .linkerd-certs/ca.key \
  --profile intermediate-ca --no-password --insecure \
  --not-after 8760h

# Create the secret
kubectl create secret generic linkerd-identity-issuer \
  --namespace=linkerd \
  --from-file=ca.crt=.linkerd-certs/ca.crt \
  --from-file=tls.crt=.linkerd-certs/issuer.crt \
  --from-file=tls.key=.linkerd-certs/issuer.key \
  --dry-run=client -o yaml | \
  kubeseal --format=yaml > .linkerd-certs/linkerd-identity-issuer.sealed.yaml


# Create the root secret with just the trust anchor (CM created directly on kustomization file)
# kubectl create configmap linkerd-identity-trust-roots \
#   --namespace=linkerd \
#   --from-file=ca-bundle.crt=ca.crt \
#   --dry-run=client -o yaml > linkerd-identity-trust-roots.yaml

# Get the current kubectl context
current_context=$(kubectl config current-context)

if [ -d "$current_context" ]; then
  # Move the files to the directory named after the current context
  mv .linkerd-certs/linkerd-identity-issuer.sealed.yaml "$current_context/"
  mv .linkerd-certs/ca.crt "$current_context/"

  echo "Files moved to the folder: $current_context"
else
  echo "Files where not moved to the folder $current_context because it does not exist."
  echo "You can move them manually if you want."
  echo "Files are located in the .linkerd-certs directory."
fi