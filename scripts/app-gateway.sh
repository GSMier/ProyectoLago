APP_SRC_PATH=../app-gateway/application-gateway-typescript
source ~/.env

presetup(){
    echo Installing npm packages ...
    pushd $APP_SRC_PATH
    npm install
    npm run build
    popd
    echo Finishing installing npm dependencies
}

# presetup

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
    # npm start update /root/blockchain/scripts/prueba.json
    # npm start history S0_bga_10_77402_QGSII_flat_defaults_DAT000703
    npm start getAllRecords
    # npm start delete S0_bga_10_77402_QGSII_flat_defaults_DAT000703
    # npm start update "002" "BlueNew" 5 "Prueba2" 10000
    # npm start create "002" "BlueNew" "Prueba2"
popd
}
# GetAllAssets    

        docker run \
            --env PEER_ENDPOINT=${PEER0_ORG0_HOST}:${PEER0_ORG0_PORT_GENERAL} \
            --env MSP_ID=${ORG0_MSPID} \
            --env CERT_DIRECTORY_PATH=/etc/data/${ORG0_NAME}/users/${USER0_ORG0_NAME}/msp/signcerts/ \
            --env KEY_DIRECTORY_PATH=/etc/data/${ORG0_NAME}/users/${USER0_ORG0_NAME}/msp/keystore/ \
            --env TLS_CERT_PATH=/etc/data/${ORG0_NAME}/tlsca/tlsca.${ORG0_NAME}-cert.pem \
            --env CHANNEL_NAME=lagochannel \
            --env CHAINCODE_NAME=scientific-data-collection \
            --env PEER_HOST_ALIAS=${PEER0_ORG0_HOST} \
            --add-host=$PEER0_ORG0_HOST:host-gateway \
            -v /home/gianm/ProyectoLago/channel/crypto-config/peerOrganizations:/etc/data \
            sebstiian/lagochain-app:1.1.0 \
            sh -c "npm start getAllRecords"
            # -v ${FILE}:/var/data/${FILE_NAME} \

docker run \
    --env PEER_ENDPOINT=${PEER0_ORG0_HOST}:${PEER0_ORG0_PORT_GENERAL} \
    --env MSP_ID=${ORG0_MSPID} \
    --env CERT_DIRECTORY_PATH=/etc/data/${ORG0_NAME}/users/${USER0_ORG0_NAME}/msp/signcerts/ \
    --env KEY_DIRECTORY_PATH=/etc/data/${ORG0_NAME}/users/${USER0_ORG0_NAME}/msp/keystore/ \
    --env TLS_CERT_PATH=/etc/data/${ORG0_NAME}/tlsca/tlsca.${ORG0_NAME}-cert.pem \
    --env CHANNEL_NAME=lagochannel \
    --env CHAINCODE_NAME=scientific-data-collection \
    --env PEER_HOST_ALIAS=${PEER0_ORG0_HOST} \
    --add-host=$PEER0_ORG0_HOST:host-gateway \
    -v /home/gianm/ProyectoLago/channel/crypto-config/peerOrganizations:/etc/data \
    -v ${FILE}:/var/data/${FILE_NAME} \
    -v /home/gianm/lagoData:/var/data \
    sebstiian/lagochain-app:1.1.0 \
    sh -c "npm start create /var/data/${FILE_NAME}"

