#! /bin/bash
echo "kube-zookeeper related environs"
env | grep '^KUBE_ZK_\|^NAMESPACE\|^CLUSTER_DOMAIN'

if [ ! -z "$KUBE_ZK_MY_ID" ] && [ ! -z "$KUBE_ZK_MAX_SERVERS" ]; then
  echo "Starting up in clustered mode"
  echo "" >> /opt/zookeeper/conf/zoo.cfg
  echo "#Server List" >> /opt/zookeeper/conf/zoo.cfg
  if [ -z "$KUBE_ZK_HOSTNAME_PREFIX" ] || [ -z "$KUBE_ZK_SUB_DOMAIN" ] || [ -z $NAMESPACE ] || [ -z $CLUSTER_DOMAIN ]; then
    echo "KUBE_ZK_HOSTNAME_PREFIX and KUBE_ZK_SUB_DOMAIN and NAMESPACE and CLUSTER_DOMAIN must be set."
    exit 1
  fi
  for i in $( eval echo {1..$KUBE_ZK_MAX_SERVERS});do
    if [ "$KUBE_ZK_MY_ID" = "$i" ];then
      echo "server.$i=0.0.0.0:2888:3888" >> /opt/zookeeper/conf/zoo.cfg
    else
      fqdn="${KUBE_ZK_HOSTNAME_PREFIX:-myid-}$i.${KUBE_ZK_SUB_DOMAIN}.${NAMESPACE}.svc.${CLUSTER_DOMAIN}"
      echo "server.$i=${fqdn}:2888:3888" >> /opt/zookeeper/conf/zoo.cfg
    fi
  done
  cat /opt/zookeeper/conf/zoo.cfg

  # Persists the ID of the current instance of Zookeeper
  echo ${KUBE_ZK_MY_ID} > /opt/zookeeper/data/myid
  else
	  echo "Starting up in standalone mode"
fi

# start up timing jitter
sleep $(( (RANDOM % $KUBE_ZK_MAX_SERVERS) + 1))

exec /opt/zookeeper/bin/zkServer.sh start-foreground
