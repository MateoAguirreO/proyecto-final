#!/bin/bash
echo "Esperando nodos del cluster..."
while true; do
  NODES=$(kubectl get nodes --no-headers 2>/dev/null | wc -l)
  echo "$(date '+%H:%M:%S') - Nodos: $NODES/2"
  
  if [ $NODES -ge 2 ]; then
    echo "Nodos listos!"
    kubectl get nodes
    echo ""
    echo "Esperando pods..."
    sleep 30
    kubectl get pods -n genosentinel
    echo ""
    echo "Esperando servicios..."
    kubectl get svc -n genosentinel
    break
  fi
  
  sleep 30
done
