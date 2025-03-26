. env-var.sh
. utils.sh
source ~/.env
CHANNEL_NAME='lagochannel'
CC_NAME="scientific-data-collection"

docker start ${PEER0_ORG0_HOST} 
docker exec ${PEER0_ORG0_HOST} chmod -R 777 /var/hyperledger/production
docker stop ${PEER0_ORG0_HOST}

rm -rf ../peers/${PEER0_ORG0_HOST}/ledgersData/
rm -rf ../peers/${PEER0_ORG0_HOST}/chaincodes/

docker start ${PEER0_ORG0_HOST}
docker exec ${PEER1_ORG0_HOST} chmod -R 777 /var/hyperledger/production


sleep 10
FABRIC_CFG_PATH=$PWD/../channel/config
setGlobals 0 $PEER0_ORG0_PORT_GENERAL
peer channel join -b ../artifacts/${CHANNEL_NAME}.block


