. utils.sh
. env-var.sh
source ~/.env

docker exec ${PEER0_ORG0_HOST} chmod -R 777 /var/hyperledger/production

rm -rf ../peers/${PEER0_ORG0_HOST}/ledgersData/fileLock


# rm -rf /var/lib/docker/volumes/blockchain_peer0.uis/_data/ledgersData/chains/index/
docker exec peer0.uis /usr/local/bin/peer node rebuild-dbs
docker restart peer0.uis
