# /bin/bash

kubectl delete deployments --all -n oai-tutorial
kubectl delete statefulsets --all -n  oai-tutorial
kubectl delete services --all -n oai-tutorial
kubectl delete pods --all -n oai-tutorial
kubectl delete configmaps --all -n oai-tutorial
kubectl delete secrets --all -n oai-tutorial
kubectl delete jobs --all -n oai-tutorial
kubectl delete cronjobs --all -n oai-tutorial
kubectl delete replicationcontrollers --all -n oai-tutorial
kubectl delete namespaces oai-tutorial
cd /work