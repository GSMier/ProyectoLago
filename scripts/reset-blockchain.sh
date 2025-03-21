pushd ../
docker compose --env-file ~/.env down
docker container prune
docker volume rm -f $(docker volume ls -q)
docker compose --env-file ~/.env up -d
popd


pushd ../channel/
./create-artifacts.sh
popd
sleep 10
./create-channel.sh
sleep 2
./deploy-chaincode.sh
