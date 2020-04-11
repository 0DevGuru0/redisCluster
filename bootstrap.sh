#! /bin/bash

echo "--> create folders{count:6}"
mkdir cluster
cd cluster
mkdir 7000 7001 7002 7003 7004 7005

echo "--> configure each redis.conf for each nodes"
for i in {0..5}
do
cat <<EOF >> 700$i/redis.conf
port 700$i
cluster-enabled yes
cluster-config-file nodes.conf
cluster-node-timeout 5000
appendonly yes
EOF
done

echo "--> Download latest version of redis"
wget http://download.redis.io/releases/redis-5.0.5.tar.gz

echo "--> Install latest version of redis"
tar xzf redis-5.0.5.tar.gz
cd redis-5.0.5
apt update
apt install build-essential
make

# Open new terminal for each group and run redis instance
cd ./cluster/7000
../redis-5.0.5/src/redis-server ./redis.conf

cd ./cluster/7001
../redis-5.0.5/src/redis-server ./redis.conf

cd ./cluster/7002
../redis-5.0.5/src/redis-server ./redis.conf

cd ./cluster/7003
../redis-5.0.5/src/redis-server ./redis.conf

cd ./cluster/7004
../redis-5.0.5/src/redis-server ./redis.conf

cd ./cluster/7005
../redis-5.0.5/src/redis-server ./redis.conf


./redis-cli --cluster create 127.0.0.1:7000 127.0.0.1:7001 127.0.0.1:7002 127.0.0.1:7003 127.0.0.1:7004 127.0.0.1:7005 --cluster-replicas 1

./redis-cli -c -p 7001