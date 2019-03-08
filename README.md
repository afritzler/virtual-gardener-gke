# Gardener-GKE

_Disclaimer: This project sets up a Gardener landscape on a GKE cluster. This is by no means a productive setup!_

## Overview

![overview](images/overview.png)

## Prerequisites

* Kubernetes cluster (min 4x n1-standard-2 nodes)
* Domain/Zone in CloudDNS
* GCP serviceaccount
* terraform
* [yaml2json](https://github.com/bronze1man/yaml2json)
* jq
* cfssl
* openssl
* kubectl
* helm

There's a docker image with the dependencies available at [afritzler/virtual-gardener-gke](https://cloud.docker.com/repository/docker/afritzler/virtual-gardener-gke)

## Setup

### Prepare setup.yaml

First we need to clone and configure our setup

```bash
git clone https://github.com/afritzler/virtual-gardener-gke.git
cd virtual-gardener-gke
cp setup.yaml.example setup.yaml
```

#### Create GKE cluster

```bash
export GKE_CLUSTER_NAME=gardener
export GCP_PROJECT=`gcloud config get-value project`

gcloud container clusters create $GKE_CLUSTER_NAME --num-nodes=4 --machine-type=n1-standard-4 --zone=europe-west1-b --enable-basic-auth --password f00bar
```

You will need a `kubeconfig` with basic-auth user authentication:

```bash
export KUBECONFIG=/tmp/kubeconfig
gcloud container clusters get-credentials $GKE_CLUSTER_NAME --zone europe-west1-b --project $GCP_PROJECT
mv kubeconfig $KUBECONFIG
src/bin/convertkubeconfig
```

The basic authentication credentials for your cluster can be found under cluster details -> "Show credentials".

You need to enter `admin/f00bar` (from above) and it should be created at `./kubeconfig`

#### Create GCP serviceaccount

```bash
gcloud iam service-accounts create gardener --display-name "Gardener"
gcloud projects add-iam-policy-binding $GCP_PROJECT --member="serviceAccount:gardener@$GCP_PROJECT.iam.gserviceaccount.com" --role="roles/editor"
gcloud iam service-accounts keys create ./google-serviceaccount.json --iam-account gardener@$GCP_PROJECT.iam.gserviceaccount.com
```

Then, edit the `setup.yaml` accordingly (e.g. paste the contents of `google-serviceaccount.json`)

### Local dependencies

Either install dependencies locally or use the provided docker image:

```bash
docker run --rm -it -v $(pwd):/gardener -w /gardener afritzler/virtual-gardener-gke
```

### Deploy Ingress Controller + Ingress DNS Record

```bash
src/ingress-controller/deploy
```

### Deploy Etcd

Deploy the Etcd needed by the Gardener extension API server

```bash
src/etcd/deploy
```

### Deploy Identity

```bash
src/identity/deploy
```

### Deploy Virtual Kube-Apiserver

```bash
src/virtualapiserver/deploy
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

### Deploy the Gardener Dashboard

```bash
src/dashboard/deploy
```

### Accessing the Gardener Dashboard

To access the Gardener Dashboard, use

```bash
cat state/identity/dashboardurl
```

to figure out the dashboard URL.

### Interacting with the Virtual Setup

The `kubeconfig` can be found under `state/virtualapiserver/kubeconfig.yaml`. So in order to deploy something to the Gardener API server you need to run

```bash
kubectl --kubeconfig=state/virtualapiserver/kubeconfig.yaml apply -f examples/shoot.yaml
```

## Cleanup

### Remove Shoot

Delete the created shoot cluster (a simple kubectl delete shoot NAME is not allowed in order to prevent users from accidentally deleting their clusters – instead, they need to confirm upfront that the deletion is fine by annotating the shoot resource. You can use this script to do that: https://github.com/gardener/gardener/blob/master/hack/delete (./hack/delete shoot gcp-test garden-core)).

To do it the manual way

```bash
kubectl --kubeconfig=state/virtualapiserver/kubeconfig.yaml -n garden-core annotate shoot gcp-test confirmation.garden.sapcloud.io/deletion=true --overwrite
kubectl --kubeconfig=state/virtualapiserver/kubeconfig.yaml -n garden-core delete shoot gcp-test
```

### Remove Gardener Config

```bash
kubectl --kubeconfig state/virtualapiserver/kubeconfig.yaml annotate project core confirmation.garden.sapcloud.io/deletion=true --overwrite
kubectl --kubeconfig state/virtualapiserver/kubeconfig.yaml delete -f gen/gardenconfig/config.yaml
```

### Remove Gardener

```bash
helm delete --purge gardener
```

### Remove Virtual API Server

```bash
helm delete --purge virtual-apiserver
```

### Remove Identity

```bash
helm delete --purge identity
```

### Remove Gardener Dashboard

```bash
helm delete --purge gardener-dashboard
```

### Remove Etcd

```bash
helm delete --purge virtual-garden-etcd
```

### Remove Ingress Controller + DNS Record

```bash
helm delete --purge nginx-ingress-controller
# to delete the DNS record
./src/ingress-controller/destroy
```

### Remove the Garden Namespace

```bash
kubectl delete ns garden
```
