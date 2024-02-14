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
sudo helm install gnb oai-5g-ran/oai-gnb --namespace oai-tutorial
sleep 5s
export GNB_POD_NAME=$(kubectl get pods --namespace oai-tutorial -l "app.kubernetes.io/name=oai-gnb,app.kubernetes.io/instance=gnb" -o jsonpath="{.items[0].metadata.name}")
export GNB_eth0_IP=$(kubectl get pods --namespace oai-tutorial -l "app.kubernetes.io/name=oai-gnb,app.kubernetes.io/instance=gnb" -o jsonpath="{.items[*].status.podIP}")
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=oai-gnb --timeout=8m --namespace oai-tutorial
kubectl logs --namespace oai-tutorial $(kubectl get pods --namespace oai-tutorial | grep oai-amf| awk '{print $1}') | grep 'Connected'
sudo helm install nrue oai-5g-ran/oai-nr-ue/ --namespace oai-tutorial
sleep 5s
export NR_UE_POD_NAME=$(kubectl get pods --namespace oai-tutorial -l "app.kubernetes.io/name=oai-nr-ue,app.kubernetes.io/instance=nrue" -o jsonpath="{.items[0].metadata.name}")
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=oai-nr-ue --timeout=8m --namespace oai-tutorial
#check if the UE received an ip-address
kubectl exec -it -n oai-tutorial -c nr-ue $(kubectl get pods | grep oai-nr-ue | awk '{print $1}') -- ifconfig oaitun_ue1 |grep -E '(^|\s)inet($|\s)' | awk {'print $2'}
# display a bold colored message "Script executed successfully"
echo -e "\e[1;32mDeployment done successfully\e[0m"
#generate some traffic to check if the UE is connected to the internet
#kubectl exec -it -n oai-tutorial -c nr-ue $(kubectl get pods | grep oai-nr-ue | awk '{print $1}') -- ping -I oaitun_ue1 -c4 google.fr
