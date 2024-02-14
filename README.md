# Wrapper for OAI deployments on Kubernetes

This repository contains scripts to install the Open Air Interface (OAI) on a Kubernetes cluster. The scripts are based on [OAI documentation](https://gitlab.eurecom.fr/oai/cn5g/oai-cn5g-fed/-/blob/master/docs/DEPLOY_SA5G_HC.md).

## Requirements

- The 3 scripts will download a git repository, by default it will be in /work but you can change by setting `WORK_DIR` in the script.
- Make sure to use the right interface by setting `INTERFACE` in the script.


## Deploy the [Use case 1](https://gitlab.eurecom.fr/oai/cn5g/oai-cn5g-fed/-/blob/master/docs/DEPLOY_SA5G_HC.md#5-use-case-1-testing-with-monolithic-ran)

```bash
curl -fsSL https://raw.githubusercontent.com/jbcol/oai-eurecom/main/usecase1.sh
chmod +x usecase1.sh
./usecase1.sh
```

## Deploy the [Use case 2](https://gitlab.eurecom.fr/oai/cn5g/oai-cn5g-fed/-/blob/master/docs/DEPLOY_SA5G_HC.md#6-use-case-2-testing-with-f1-split-ran)

```bash
curl -fsSL https://raw.githubusercontent.com/jbcol/oai-eurecom/main/usecase2.sh
chmod +x usecase2.sh
./usecase2.sh
```

## Deploy the [Use case 3](https://gitlab.eurecom.fr/oai/cn5g/oai-cn5g-fed/-/blob/master/docs/DEPLOY_SA5G_HC.md#7-use-case-3-testing-with-e1-and-f1-split-ran)

```bash
curl -fsSL https://raw.githubusercontent.com/jbcol/oai-eurecom/main/usecase3.sh
chmod +x usecase3.sh
./usecase3.sh
```
