# postgres-patroni-local-kubernetes

Setup a postgres ha-cluster with patroni on a local multi-node kubernetes cluster on windows.

## Setup a local multi-node k8s cluster on windows

### System Requirements

#### Docker

* Hyper-V enabled
* [install Docker Desktop for Windows](https://docs.docker.com/docker-for-windows/)  
* [Settings for Docker Desktop](https://kind.sigs.k8s.io/docs/user/quick-start/)
  * enable "linux containers"

#### Basic kind installation and configuration

* install open source project [kind](https://github.com/kubernetes-sigs/kind/)
  * create directory for kind
  * sample: "c:\user\username\kind"
  * open `powershell` and type in

```yaml
curl.exe -Lo kind-windows-amd64.exe https://github.com/kubernetes-sigs/kind/releases/download/v0.7.0/kind-windows-amd64
Move-Item .\kind-windows-amd64.exe c:\user\username\kind\kind.exe
```

* set environment variables for `kind`
* test kind: type in `kind` in `powershell`

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

* create multi-node cluster: `kind create cluster --config <kind-example-config.yaml-path>` (Docker must be running!), this will take a few minutes
* test running cluster: kubectl cluster-info --context kind-kind

## Install and configure Kubernetes Dashboard

* install [kubernetes-dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/) and expose kubernetes dashboard on port 8001

1. command: `kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml`
1. command: `kubectl proxy`
1. access [kuberentes dashboard](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/)

* access-token for access: `kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')`
** copy last access-token (`token:`) on output to web-ui: token field

** alias for "kubectl" for windows powershell `Set-Alias kc "C:\path\kubectl.exe"`

### Troubleshooting

1. Missing permissions for `kubernetes-dashboard` user

* sample: admin/root permissions to administrate the k8s-cluster
** `kubectl edit clusterroles kubernetes-dashboard`
** change access to ressources to the following

clusterrole: kubernetes-dashboard

```yaml
- apiGroups:
  - '*'
  resources:
  - '*'
  verbs:
  - '*'
```

