#!/bin/bash

cd /work
sudo git clone https://gitlab.eurecom.fr/oai/cn5g/oai-cn5g-fed

sudo find /work/oai-cn5g-fed/ -type f -name "values.yaml" -exec sudo sed -i 's/eth0/enp1s0f0/g' {} +
sudo sed -i 's/enp1s0f0/eth0/g' /work/oai-cn5g-fed/charts/oai-5g-ran/oai-gnb/values.yaml
sudo sed -i 's/enp1s0f0/eth0/g' /work/oai-cn5g-fed/charts/oai-5g-ran/oai-cu/values.yaml
sudo sed -i 's/enp1s0f0/eth0/g' /work/oai-cn5g-fed/charts/oai-5g-ran/oai-cu-cp/values.yaml
sudo sed -i 's/enp1s0f0/eth0/g' /work/oai-cn5g-fed/charts/oai-5g-ran/oai-cu-up/values.yaml

# Let's install the charts
kubectl create ns oai-tutorial
kubectl config set-context --current --namespace=oai-tutorial
kubectl config view --minify | grep namespace | awk '{print $2}'

cd /work/oai-cn5g-fed/charts/
sudo helm dependency build oai-5g-core/oai-5g-basic/
sudo helm install basic oai-5g-core/oai-5g-basic/
sleep 5s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=basic --timeout=8m
sleep 5s
kubectl logs -l app.kubernetes.io/name=oai-smf -n oai-tutorial | grep 'handle_receive(16 bytes)' | wc -l
kubectl logs -l app.kubernetes.io/name=oai-upf -n oai-tutorial | grep 'handle_receive(16 bytes)' | wc -l


helm install cucp oai-cu-cp --namespace oai-tutorial
sleep 5s
export GNB__CU_POD_NAME=$(kubectl get pods --namespace oai-tutorial -l "app.kubernetes.io/name=oai-cu,app.kubernetes.io/instance=cu" -o jsonpath="{.items[0].metadata.name}")
export GNB_CU_eth0_IP=$(kubectl get pods --namespace oai-tutorial -l "app.kubernetes.io/name=oai-cu,app.kubernetes.io/instance=cu" -o jsonpath="{.items[*].status.podIP}")
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=oai-cu-cp --timeout=8m

helm install cuup oai-cu-up --namespace oai-tutorial
sleep 5s
export GNB__CU_POD_NAME=$(kubectl get pods --namespace oai-tutorial -l "app.kubernetes.io/name=oai-cu-up,app.kubernetes.io/instance=cuup" -o jsonpath="{.items[0].metadata.name}")
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=oai-cu-up --namespace oai-tutorial --timeout=8m
kubectl logs --namespace oai-tutorial $(kubectl get pods --namespace oai-tutorial | grep oai-cu-cp| awk '{print $1}') | grep 'Accepting new CU-UP ID'


helm install du oai-du --namespace oai-tutorial
sleep 5s
export GNB_DU_POD_NAME=$(kubectl get pods --namespace oai-tutorial -l "app.kubernetes.io/name=oai-du,app.kubernetes.io/instance=du" -o jsonpath="{.items[0].metadata.name}")
export GNB_DU_eth0_IP=$(kubectl get pods --namespace oai-tutorial -l "app.kubernetes.io/name=oai-du,app.kubernetes.io/instance=du" -o jsonpath="{.items[*].status.podIP}")
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=oai-du --timeout=3m --namespace oai-tutorial
kubectl logs --namespace oai-tutorial $(kubectl get pods --namespace oai-tutorial | grep oai-cu-cp| awk '{print $1}') | grep 'Received F1 Setup Request'
kubectl logs --namespace oai-tutorial $(kubectl get pods --namespace oai-tutorial | grep oai-amf| awk '{print $1}') | grep 'Connected'


echo -e "\e[1;32mDeployment done successfully\e[0m"
