# Gardener-GKE

This project sets up a Gardener landscape on a GKE cluster.

## Prerequisites

* Kubernetes cluster
* Domain/Zone in CloudDNS
* GCP serviceaccount
* terraform
* jq
* cfssl
* openssl
* kubectl
* helm

## Setup

### Prepare setup.yaml

First we need to clone and configure our setup

```bash
git clone https://github.com/afritzler/gardener-gke.git
cd gardener-gke
cp setup.yaml.example setup.yaml
```

You will need a `kubeconfig` with basic-auth user authentication.

```bash
export KUBECONFIG=/tmp/kubeconfig
gcloud container clusters get-credentials CLUSTER_NAME --zone europe-west1-b --project PROJECT_NAME
src/bin/convertkubeconfig
```

Then, edit the `setup.yaml` accordingly.

### Deploy Etcd

Deploy the Etcd needed by the Gardener extension API server

```bash
src/etcd/deploy
```

### Deploy Ingress Controller + Ingress DNS Record

```bash
src/ingress-controller/deploy
```

### Deploy Gardener

Deploy the Gardener extension API server and controller

```bash
src/gardener/deploy
```

### Configure the Gardener Landscape

Deploy and configure CloudProfile, Seed, etc ...

```bash
src/gardenconfig/deploy
```