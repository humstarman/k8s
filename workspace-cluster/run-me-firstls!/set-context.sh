#!/bin/bash

set -e

CONTEXT=dc
NAMESPACEi=datacentre

kubectl config use-context kubernetes
CURRENT_CONTEXT=$(kubectl config view -o jsonpath='{.current-context}')
USER_NAME=$(kubectl config view -o jsonpath='{.contexts[?(@.name == "'"${CURRENT_CONTEXT}"'")].context.user}')
CLUSTER_NAME=$(kubectl config view -o jsonpath='{.contexts[?(@.name == "'"${CURRENT_CONTEXT}"'")].context.cluster}')
kubectl config set-context $CONTEXT --namespace=$NAMESPACE --cluster=${CLUSTER_NAME} --user=${USER_NAME}
kubectl config use-context $CONTEXT

