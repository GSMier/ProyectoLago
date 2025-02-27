. utils.sh
. env-var.sh
source /root/.env



rm -rf /var/lib/docker/volumes/blockchain_peer0.uis/_data/ledgersData/fileLock
# rm -rf /var/lib/docker/volumes/blockchain_peer0.uis/_data/ledgersData/chains/index/
sudo docker exec peer0.uis /usr/local/bin/peer node rebuild-dbs
docker restart peer0.uis
