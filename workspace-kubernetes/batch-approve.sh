#!/bin/bash

CSRS=$(kubectl get csr | grep Pending | awk -F ' ' '{print $1}')

if [ -n "$CSRS" ]; then
  for CSR in $CSRS; do
    kubectl certificate approve $CSR
  done
fi
