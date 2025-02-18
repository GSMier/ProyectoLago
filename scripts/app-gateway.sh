APP_SRC_PATH=../app-gateway/application-gateway-typescript
source /root/.env

presetup(){
    echo Installing npm packages ...
    pushd $APP_SRC_PATH
    npm install
    npm run build
    popd
    echo Finishing installing npm dependencies
}

presetup

export PEER_ENDPOINT=localhost:7051
export MSP_ID=$ORG0_MSPID
export CERT_DIRECTORY_PATH=${PWD}/../channel/crypto-config/peerOrganizations/${ORG0_NAME}/users/${USER0_ORG0_NAME}/msp/signcerts/
export KEY_DIRECTORY_PATH=${PWD}/../channel/crypto-config/peerOrganizations/${ORG0_NAME}/users/${USER0_ORG0_NAME}/msp/keystore/
export TLS_CERT_PATH=${PWD}/../channel/crypto-config/peerOrganizations/${ORG0_NAME}/tlsca/tlsca.${ORG0_NAME}-cert.pem

export CHANNEL_NAME='lagochannel'
export CHAINCODE_NAME='scientific-data-collection'
export PEER_HOST_ALIAS=localhost

# export PEER_ENDPOINT=localhost:7051
# export MSP_ID='Org1MSP'
# export CERT_DIRECTORY_PATH=${PWD}/credentialsTest/signcerts/
# export KEY_DIRECTORY_PATH=${PWD}/credentialsTest/keystore/
# export TLS_CERT_PATH=${PWD}/../channel/crypto-config/peerOrganizations/org1.example.com/tlsca/tlsca.org1.example.com-cert.pem
# export CHANNEL_NAME='mychannel'
# export CHAINCODE_NAME='asset-transfer'
# export PEER_HOST_ALIAS=localhost

GetAllAssets(){

pushd $APP_SRC_PATH
    npm start read "ESPOCH_nogps_2016_05_20_00h00"
    # npm start update "002" "BlueNew" 5 "Prueba2" 10000
    # npm start create "002" "BlueNew" "Prueba2"
popd
}
GetAllAssets    