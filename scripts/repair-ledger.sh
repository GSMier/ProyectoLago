. env-var.sh
. utils.sh
source ~/.env
CHANNEL_NAME='lagochannel'
docker stop peer0.uis

rm -rf /var/lib/docker/volumes/blockchain_${PEER0_ORG0_HOST}/_data/ledgersData/
rm -rf /var/lib/docker/volumes/blockchain_${PEER0_ORG0_HOST}/_data/chaincodes/

docker start peer0.uis

FABRIC_CFG_PATH=$PWD/../channel/config

sleep 10
setGlobals 0 $PEER0_ORG0_PORT_GENERAL
peer channel join -b ../artifacts/${CHANNEL_NAME}.block
rm -rf /var/lib/docker/volumes/${PEER0_ORG0_HOST}/_data/ledgersData/fileLock
sudo docker exec peer0.uis /usr/local/bin/peer node rebuild-dbs
docker restart peer0.uis
