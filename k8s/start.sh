#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHART_DIR="${SCRIPT_DIR}/zeroclaw"
NAMESPACE="prod"

echo "========================================"
echo "  ZeroClaw K8s Deployment"
echo "========================================"
echo ""

if [ ! -d "$CHART_DIR" ]; then
    echo "Error: Chart directory not found: $CHART_DIR"
    exit 1
fi

echo "Chart directory: $CHART_DIR"
echo "Namespace: $NAMESPACE"
echo ""

echo "[1/2] Checking if namespace exists..."
if ! kubectl get namespace "$NAMESPACE" > /dev/null 2>&1; then
    echo "      Creating namespace: $NAMESPACE"
    kubectl create namespace "$NAMESPACE"
fi
echo "      ✓ Namespace ready"
echo ""

echo "[2/2] Deploying Helm chart..."
helm upgrade --install zeroclaw "$CHART_DIR" -n "$NAMESPACE" --wait --timeout 2m
echo "      ✓ Deployment complete"
echo ""

echo "[4/4] Checking pods status..."
echo ""
kubectl get pods -n "$NAMESPACE" -l app.kubernetes.io/name=zeroclaw
echo ""

echo "========================================"
echo "  Deployment Info"
echo "========================================"
echo ""
echo "Services:"
kubectl get svc -n "$NAMESPACE" | grep zeroclaw || echo "  (none)"
echo ""
echo "Storage (PVC):"
kubectl get pvc -n "$NAMESPACE" | grep zeroclaw || echo "  (none)"
echo ""
echo "========================================"
echo ""
echo "To view logs:"
echo "  kubectl logs -f zeroclaw-0 -n prod"
echo "  kubectl logs -f zeroclaw-1 -n prod"
echo ""
echo "To uninstall (keep namespace):"
echo "  helm uninstall zeroclaw -n prod"
echo ""
