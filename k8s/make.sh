echo "->>Set variables"
storageFolder=/srv/nfs/kubedata
storageFolderCount=6
pvsFolder=./k8s
stsFile=sts.yml

echo "->>Install dependencies"
apt update &>/dev/null
apt install nfs-kernel-server -y &>/dev/null
systemctl enable nfs-server
systemctl start nfs-server

echo "->>Configure nfs & pv "
echo "$storageFolder     *(rw,sync,no_subtree_check,insecure)" >> /etc/exports
mkdir -p "$storageFolder"
mkdir -p $pvsFolder

for (( i = 0; i < $storageFolderCount ; i++))
do
    mkdir "$storageFolder/pv$i"
cat <<EOF >>$pvsFolder/pv$i.yml
apiVersion: v1
kind: PersistentVolume
metadata:
 name: pv-nfs-pv$i
 labels:
  type: local
spec:
 storageClassName: manual
 capacity:
  storage: 200Mi
 accessModes:
  - ReadWriteOnce
 nfs:
  server: $(kubectl get nodes -o=jsonpath='{.items[0].status.addresses[0].address}')
  path: /srv/nfs/kubedata/pv$i
EOF
done
chmod -R 777 $storageFolder
exportfs -rav

echo "->>Apply k8s pvs,statefulset,service"
kubectl apply -f $pvsFolder/
kubectl apply -f $stsFile

echo "->>END Operation"

# kubectl exec -it redis-cluster-0 -- redis-trib create --replicas 1 $(kubectl get pods -l app=redis-cluster -o jsonpath='{range.items[*]}{.status.podIP}:6379 ')
# kubectl exec redis-cluster-0 -it -- redis-cli -h $(hostname) -c

# Ref:https://medium.com/zero-to/setup-persistence-redis-cluster-in-kubertenes-7d5b7ffdbd98