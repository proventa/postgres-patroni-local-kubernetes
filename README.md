# postgres-patroni-local-kubernetes

Setup a PostgreSQL-HA-Cluster with Patroni on a local multi-node kubernetes cluster on windows and linux mint.

## Setup a local multi-node k8s cluster

### System Requirements

#### Docker

* Hyper-V enabled (Windows)
* [install Docker Desktop for Windows](https://docs.docker.com/docker-for-windows/)
  * Enable "linux containers"
  * [Settings for Docker Desktop](https://kind.sigs.k8s.io/docs/user/quick-start/)
* [Install Docker on Linux](https://docs.docker.com/install/linux/docker-ce/ubuntu/)

#### Basic kind installation and configuration

* Install the open source project [kind](https://github.com/kubernetes-sigs/kind/)
  * Create directory for kind
    * Windows: "c:\user\username\kind"

```console
curl.exe -Lo kind-windows-amd64.exe https://github.com/kubernetes-sigs/kind/releases/download/v0.7.0/kind-windows-amd64
Move-Item .\kind-windows-amd64.exe $pwd\kind.exe
```

   * Linux: `mkdir -p /kubernetes-local/kind`

```console
curl -Lo ./kind "https://github.com/kubernetes-sigs/kind/releases/download/v0.7.0/kind-$(uname)-amd64"
chmod +x ./kind
mv ./kind /kubernetes-local/kind
```

* Set environment variables for `kind`
  * Windows (as Administrator): `[Environment]::SetEnvironmentVariable("Path", $env:Path + ";$pwd", "User")` 
  * linux: `cp ~/kubernetes-local/kind/./kind /usr/local/bin` and add path to `.zshrc` or `.bashrc`
* Test if kind is working: type in `kind` in `powershell` or `bash`

### Sample Multi-node cluster (1 master, 2 workers)

* [Multinode-cluster](https://kind.sigs.k8s.io/docs/user/quick-start/) (Section: Advanced/Configuring Your kind Cluster)
  * Create `kind-example-config.yaml` under c:/user/username/kind

sample kind-example-config.yaml

```yaml
## Three node (two workers) k8s-cluster config
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
```

* Create multi-node cluster (this will take a few minutes): `kind create cluster --config <kind-example-config.yaml-path>` (Docker must be running!)
* Test running cluster: kubectl cluster-info --context kind-kind

## Install and configure Kubernetes Dashboard

* Install [kubernetes-dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/) and expose kubernetes dashboard on port 8001

1. Command: `kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml`
1. Command: `kubectl proxy`
1. Access [kuberentes dashboard](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/)

* Access-token for access: `kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')`
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

* Copy last access-token (`token:`) on output to web-ui: token field

* Alias for "kubectl" for windows powershell `Set-Alias kc "C:\path\kubectl.exe"`

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

In the `patroni` folder are YAML-Manifest and a script for the automated deployment of on PostgreSQL-HA-Cluster with patroni.

### Steps

1. clone this repository
1. `chmod +x setup-patroni-cluster.sh`
1. `kubectl create namespace zalando-postgres`
1. `./setup-patroni-cluster.sh`

### Useful

* forward a port from a deployment
```bash
kubectl get pods -n <namespace>
kubectl port-forward <pod-name> hostport:pod-port -n namespace
```
