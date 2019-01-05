# Gardener-GKE

This project sets up a Gardener landscape on a GKE cluster.

## Prerequisites

* Kubernetes cluster
* Domain/Zone in CloudDNS
* GCP serviceaccount
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

Edit the `setup.yaml` accordingly.

The Diffie-Hellmann key can be created with via openssl

```bash
openssl genpkey -genparam -algorithm DH -out gen/dhp.pem
```

### Deploy Etcd

```bash
src/etcd/deploy
```

### Deploy Gardener

```bash
src/gardener/deploy
```

### Configure the Gardener Landscape

```
src/gardenconfig/deploy
```