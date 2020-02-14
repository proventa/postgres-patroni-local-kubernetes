# postgres-patroni-local-kubernetes

Setup a postgres ha-cluster with patroni on a local multi-node kubernetes cluster on windows and linux mint.

## Setup a local multi-node k8s cluster

### System Requirements

#### Docker

* Hyper-V enabled (Windows)
* [install Docker Desktop for Windows](https://docs.docker.com/docker-for-windows/)
* [install Docker on Linux](https://docs.docker.com/install/linux/docker-ce/ubuntu/)  
* [Settings for Docker Desktop](https://kind.sigs.k8s.io/docs/user/quick-start/)
  * enable "linux containers"

#### Basic kind installation and configuration

* install open source project [kind](https://github.com/kubernetes-sigs/kind/)
  * create directory for kind
    * windows: "c:\user\username\kind"
    * linux: `mkdir -p /kubernetes-local/kind`
  * `powershell` and type in

```console
curl.exe -Lo kind-windows-amd64.exe https://github.com/kubernetes-sigs/kind/releases/download/v0.7.0/kind-windows-amd64
Move-Item .\kind-windows-amd64.exe c:\user\username\kind\kind.exe
```

  * `bash` and type in

```console
curl -Lo ./kind "https://github.com/kubernetes-sigs/kind/releases/download/v0.7.0/kind-$(uname)-amd64"
chmod +x ./kind
mv ./kind /kubernetes-local/kind
```

* set environment variables for `kind`
  * linux: `cp ~/kubernetes-local/kind/./kind /usr/local/bin` and add path to `.zshrc` or `.bashrc`
* test kind: type in `kind` in `powershell` or `bash`

### Sample Multi-node cluster (1 master, 2 workers)

* [multinode-cluster](https://kind.sigs.k8s.io/docs/user/quick-start/) (Section: Advanced/Configuring Your kind Cluster)
  * create `kind-example-config.yaml` under c:/user/username/kind

kind-example-config.yaml

```yaml
## Three node (two workers) k8s-cluster config
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
```

* create multi-node cluster (this will take a few minutes): `kind create cluster --config <kind-example-config.yaml-path>` (Docker must be running!)
* test running cluster: kubectl cluster-info --context kind-kind

## Install and configure Kubernetes Dashboard

* install [kubernetes-dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/) and expose kubernetes dashboard on port 8001

1. command: `kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml`
1. command: `kubectl proxy`
1. access [kuberentes dashboard](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/)

* access-token for access: `kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')`
* sample output:

```console
Name:         kubernetes-dashboard-token-jdxjs
Namespace:    kubernetes-dashboard
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: kubernetes-dashboard
              kubernetes.io/service-account.uid: aceae174-dd49-4193-aa6d-2947e04e2170

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1025 bytes
namespace:  20 bytes
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6InpRV1h1dmpYM25YdUNQeFF6N2hWUkZiQlFmdEw1RDY5M01WQlQ2aGx4dlUifQOA9U-2OMCbCzhhTAKc9kwIK3SxUZLLGU9qJ_FwAYWi3yWmlXwnhxyiDIvP-CqxHvf-trYeevd1djRnq-hWP5nFrafEsm90brt_7YsEGZH1ELGVp1CyD5cf9lw

```

* copy last access-token (`token:`) on output to web-ui: token field

* alias for "kubectl" for windows powershell `Set-Alias kc "C:\path\kubectl.exe"`

### Troubleshooting

1. Missing permissions for `kubernetes-dashboard` user to list, edit, ... ressources

* sample: admin/root permissions to administrate the k8s-cluster
* `kubectl edit clusterroles kubernetes-dashboard`
* change access to ressources to the following

clusterrole: kubernetes-dashboard

```yaml
- apiGroups:
  - '*'
  resources:
  - '*'
  verbs:
  - '*'
```

## Setup Postgres-HA with Patroni

1. clone this repository
1. `chmod +x setup-patroni-cluster.sh`
1. `kubectl create namespace zalando-postgres`
1. `./setup-patroni-cluster.sh`