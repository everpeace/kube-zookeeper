kube-zookeeper
================================
[![Build Status](https://travis-ci.org/everpeace/kube-zookeeper.svg?branch=master)](https://travis-ci.org/everpeace/kube-zookeeper)

[docker-hub](https://hub.docker.com/r/everpeace/kube-zookeeper/)

A docker image for running ZooKeeper ensemble in Kubernetes.

## Supported tags

`latest`/`3.4.5-0.1.0` (ZooKeeper v3.4.5)

Naming convention for images is `$ZK_VERSION`-`$KUBE_ZK_VERSION`

## Changelog
- `0.1.0`
  - initial release.
  - based on ZooKeeper 3.4.5

## Using in Kubernetes
The image supports the following ZooKeeper modes:

* Clustered
* Standalone

### Clustered Mode
First, you need to be sure [kube-dns](https://kubernetes.io/docs/admin/dns/) is running in your kubernetes cluster.  This image assumes each pod which consists of zookeeper ensemble can be resolved by Kubernetes' DNS.

```
# (1) create Headless Service to setup subdomain for zookeeper ensemble
$ kubectl create -f zookeeper.svc.yaml
# (2) start zookeeper ensemble which consists three pods in the example
$ kubectl create -f zookeeper.pod.yaml
```

#### Configuration
To start the image in clustered mode you need to specify a couple of environment variables for the container.

| Environment Variable                          | Description                           |
| --------------------------------------------- | --------------------------------------|
| KUBE_ZK_MY_ID                                 | The id of the  server                 |
| KUBE_ZK_MAX_SERVERS                           | The number of servers in the ensemble |
| KUBE_ZK_HOSTNAME_PREFIX                       | The prefix of hostname(default: `myid-`). This must be matched with 'spec.hostname' in the pod definition. |
| KUBE_ZK_SUBDOMAIN                             | subdomain in which the ensemble lives. This must be matched with 'spec.subdomain' in the pod definition. |
| NAMESPACE                                     | namespace in which the pod lives.     |
| CLUSTER_DOMAIN                                | cluster domain of kubernetes cluster  |

Each container started with all of the above variables will use the following env variable setup (for example, let `KUBE_ZK_MAX_SERVERS=N`, `KUBE_ZK_HOSTNAME_PREFIX=myid-`, `KUBE_ZK_SUB_DOMAIN=zookeeper`, `NAMESPACE=default`, `CLUSTER_DOMAIN=cluster.local`):

    server.1=myid-1.zookeeper.default.svc.cluster.local:2888:3888
    server.2=myid-2.zookeeper.default.svc.cluster.local:2888:3888
    server.3=myid-3.zookeeper.default.svc.cluster.local:2888:3888
    ...
    server.N=myid-N.zookeeper.default.svc.cluster.local:2888:3888

### Standalone Mode
To start the image in standalone mode you can simply use:

    kubectl run zk-standalone --image=everpeace/kube-zookeeper --quiet --rm -i --tty --restart=Never
