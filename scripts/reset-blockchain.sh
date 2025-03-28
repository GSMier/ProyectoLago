pushd ../
docker compose --env-file ~/.env up -d
docker exec peer0.uis chmod -R 777 /var/hyperledger 
docker exec peer1.uis chmod -R 777 /var/hyperledger 
docker exec peer2.uis chmod -R 777 /var/hyperledger 
docker exec peer0.espoch chmod -R 777 /var/hyperledger 
docker exec peer1.espoch chmod -R 777 /var/hyperledger 
docker exec peer2.espoch chmod -R 777 /var/hyperledger 
docker exec orderer0 chmod -R 777 /var/hyperledger
docker exec orderer1 chmod -R 777 /var/hyperledger
docker exec orderer2 chmod -R 777 /var/hyperledger
docker compose --env-file ~/.env down
docker container prune
docker volume rm -f $(docker volume ls -q)
rm -rf peers/
rm -rf orderers/
docker compose --env-file ~/.env up -d
popd


pushd ../channel/
./create-artifacts.sh
popd
sleep 10
./create-channel.sh
sleep 2
./deploy-chaincode.sh
sleep 5
./collect-data.sh