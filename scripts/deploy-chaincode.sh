. env-var.sh
. utils.sh
source /root/.env

CHANNEL_NAME="lagochannel"
CC_RUNTIME_LANGUAGE="node"
VERSION="1"
SEQUENCE=1
CC_SRC_PATH=../chaincode/chaincode-typescript
CC_NAME="scientific-data-collection"
CC_POLICY="OutOf(4,'UISMSP.peer','UISMSP.peer','UISMSP.peer','ESPOCHMSP.peer','ESPOCHMSP.peer','ESPOCHMSP.peer')"

presetup(){
    echo Installing npm packages ...
    pushd $CC_SRC_PATH
    npm install
    npm run build
    popd
    echo Finishing installing npm dependencies
}
# presetup

packageChaincode() {
    rm -rf ${CC_NAME}.tar.gz
    setGlobals 0
    peer lifecycle chaincode package ${CC_NAME}.tar.gz \
        --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
        --label ${CC_NAME}_${VERSION}
    echo "===================== Chaincode is packaged ===================== "

    
}
# packageChaincode

installChaincode() {

    setGlobals 0 $PEER0_ORG0_PORT_GENERAL
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.org0 ===================== "

    setGlobals 0 $PEER1_ORG0_PORT_GENERAL
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer1.org0 ===================== "

    setGlobals 0 $PEER2_ORG0_PORT_GENERAL
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer2.org0 ===================== "

    setGlobals 1 $PEER0_ORG1_PORT_GENERAL
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.org1 ===================== "

    setGlobals 1 $PEER1_ORG1_PORT_GENERAL
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer1.org1 ===================== "
    
    setGlobals 1 $PEER2_ORG1_PORT_GENERAL
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer2.org1 ===================== "
}

# installChaincode

queryInstalled() {
    setGlobals $1 $2
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID=$(sed -n "/${CC_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful on peer port ${2} ===================== "
}
# queryInstalled 0 $PEER0_ORG0_PORT_GENERAL


#* Se necesita el package id por lo que es necesario hacer un queryinstalled para la org
approveForMyOrg() {
    setGlobals $1
    peer lifecycle chaincode approveformyorg -o localhost:${ORDERER0_PORT_GENERAL} \
        --ordererTLSHostnameOverride $ORDERER0_HOST --tls \
        --signature-policy ${CC_POLICY} \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --package-id ${PACKAGE_ID} \
        --sequence ${SEQUENCE} \
        # --init-required

    echo "===================== chaincode approved from org ${1} ===================== "

}

# approveForMyOrg 0

checkCommitReadyness() {
    setGlobals $1
    peer lifecycle chaincode checkcommitreadiness \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --signature-policy ${CC_POLICY} \
        --sequence ${SEQUENCE} --output json \
        # --init-required
    echo "===================== checking commit readyness from org ${1} ===================== "
}

# checkCommitReadyness 0

# queryInstalled 1 $PEER2_ORG1_PORT_GENERAL
# approveForMyOrg 1
# checkCommitReadyness 1


commitChaincodeDefination() {
    setGlobals $1
    peer lifecycle chaincode commit -o localhost:${ORDERER0_PORT_GENERAL} --ordererTLSHostnameOverride $ORDERER0_HOST \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        --signature-policy ${CC_POLICY} \
        --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --peerAddresses localhost:${PEER0_ORG0_PORT_GENERAL} --tlsRootCertFiles $PEER0_ORG0_CA \
        --peerAddresses localhost:${PEER1_ORG0_PORT_GENERAL} --tlsRootCertFiles $PEER1_ORG0_CA \
        --peerAddresses localhost:${PEER2_ORG0_PORT_GENERAL} --tlsRootCertFiles $PEER2_ORG0_CA \
        --peerAddresses localhost:${PEER0_ORG1_PORT_GENERAL} --tlsRootCertFiles $PEER0_ORG1_CA \
        --peerAddresses localhost:${PEER1_ORG1_PORT_GENERAL} --tlsRootCertFiles $PEER1_ORG1_CA \
        --peerAddresses localhost:${PEER2_ORG1_PORT_GENERAL} --tlsRootCertFiles $PEER2_ORG1_CA \
        --version ${VERSION} --sequence ${SEQUENCE} \
        # --init-required

}

# commitChaincodeDefination 1

queryCommitted() {
    setGlobals 1
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}

}


# queryCommitted

chaincodeInvoke() {
    setGlobals $1

    # Create Car
    peer chaincode invoke -o localhost:${ORDERER0_PORT_GENERAL} \
        --ordererTLSHostnameOverride $ORDERER0_HOST \
        --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses localhost:${PEER0_ORG0_PORT_GENERAL} --tlsRootCertFiles $PEER0_ORG0_CA \
        --peerAddresses localhost:${PEER1_ORG0_PORT_GENERAL} --tlsRootCertFiles $PEER1_ORG0_CA \
        --peerAddresses localhost:${PEER2_ORG0_PORT_GENERAL} --tlsRootCertFiles $PEER2_ORG0_CA \
        --peerAddresses localhost:${PEER0_ORG1_PORT_GENERAL} --tlsRootCertFiles $PEER0_ORG1_CA \
        --peerAddresses localhost:${PEER1_ORG1_PORT_GENERAL} --tlsRootCertFiles $PEER1_ORG1_CA \
        --peerAddresses localhost:${PEER2_ORG1_PORT_GENERAL} --tlsRootCertFiles $PEER2_ORG1_CA \
        -c '{"Args":["CreateAsset","001","Red","52","Fred","234234"]}'

        # --isInit \
        # -c '{"Args":[]}'

}


# chaincodeInvoke 1

chaincodeQuery() {
    setGlobals 0 $PEER2_ORG0_PORT_GENERAL
    peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function": "GetAllAssets","Args":[]}'
}

# chaincodeQuery



# To execute everything
# presetup
# approveForMyOrg 0

checkCommitReadyness() {
    setGlobals $1
    peer lifecycle chaincode checkcommitreadiness \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --signature-policy ${CC_POLICY} \
        --sequence ${SEQUENCE} --output json \
        # --init-required
    echo "===================== checking commit readyness from org ${1} ===================== "
}

# checkCommitReadyness 0

# queryInstalled 1 $PEER2_ORG1_PORT_GENERAL
# approveForMyOrg 1
# checkCommitReadyness 1


commitChaincodeDefination() {
    setGlobals $1
    peer lifecycle chaincode commit -o localhost:${ORDERER0_PORT_GENERAL} --ordererTLSHostnameOverride $ORDERER0_HOST \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        --signature-policy ${CC_POLICY} \
        --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --peerAddresses localhost:${PEER0_ORG0_PORT_GENERAL} --tlsRootCertFiles $PEER0_ORG0_CA \
        --peerAddresses localhost:${PEER1_ORG0_PORT_GENERAL} --tlsRootCertFiles $PEER1_ORG0_CA \
        --peerAddresses localhost:${PEER2_ORG0_PORT_GENERAL} --tlsRootCertFiles $PEER2_ORG0_CA \
        --peerAddresses localhost:${PEER0_ORG1_PORT_GENERAL} --tlsRootCertFiles $PEER0_ORG1_CA \
        --peerAddresses localhost:${PEER1_ORG1_PORT_GENERAL} --tlsRootCertFiles $PEER1_ORG1_CA \
        --peerAddresses localhost:${PEER2_ORG1_PORT_GENERAL} --tlsRootCertFiles $PEER2_ORG1_CA \
        --version ${VERSION} --sequence ${SEQUENCE} \
        # --init-required

}

# commitChaincodeDefination 1

queryCommitted() {
    setGlobals 1
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}

}


# queryCommitted

chaincodeInvoke() {
    setGlobals $1

    # Create Car
    peer chaincode invoke -o localhost:${ORDERER0_PORT_GENERAL} \
        --ordererTLSHostnameOverride $ORDERER0_HOST \
        --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses localhost:${PEER0_ORG0_PORT_GENERAL} --tlsRootCertFiles $PEER0_ORG0_CA \
        --peerAddresses localhost:${PEER1_ORG0_PORT_GENERAL} --tlsRootCertFiles $PEER1_ORG0_CA \
        --peerAddresses localhost:${PEER2_ORG0_PORT_GENERAL} --tlsRootCertFiles $PEER2_ORG0_CA \
        --peerAddresses localhost:${PEER0_ORG1_PORT_GENERAL} --tlsRootCertFiles $PEER0_ORG1_CA \
        --peerAddresses localhost:${PEER1_ORG1_PORT_GENERAL} --tlsRootCertFiles $PEER1_ORG1_CA \
        --peerAddresses localhost:${PEER2_ORG1_PORT_GENERAL} --tlsRootCertFiles $PEER2_ORG1_CA \
        -c  '{"function": "CreateRecord","Args":["{\"Id\":\"ESPOCH_nogps_2016_05_20_00h00\",\"type\":\"L0\",\"generationDate\":\"2016 05_20_00:00:00\",\"metadata\":\"7113932e4ca8bbb14dc9b1a5211ecc2d5eedf6a464a1dbf04f801ea070554f55\",\"rawData\":\"60939e3fed5a9a42fbafc9a88642eefaf6d72cb6b365ab290cf70ff3f1d070a0\",\"inputData\":null,\"inputMetadata\":null,\"outputData\":null,\"outputMetadata\":null,\"siteName\":\"\\\"Escuela Superior Politécnica de Chimborazo\\\"\",\"collaboratorName\":\"\\\"Mario Audelo\\\"\",\"orcid\":\"\\\"0000-0000-0000-0000\\\"\",\"accessUrl\":null}"]}' 
        # -c '{"Args":["CreateRecord",{\"ID\":\"ESPOCH_nogps_2016_05_20_00h00\",\"Type\":\"L0\",\"GenerationDate\":\"2016 05_20_00:00:00\",\"Metadata\":\"7113932e4ca8bbb14dc9b1a5211ecc2d5eedf6a464a1dbf04f801ea070554f55\",\"Rawdata\":\"60939e3fed5a9a42fbafc9a88642eefaf6d72cb6b365ab290cf70ff3f1d070a0\",\"inputData\":null,\"inputMetadata\":null,\"outputData\":null,\"outputMetadata\":null,\"SiteName\":\"\\\"Escuela Superior Politécnica de Chimborazo\\\"\",\"collaboratorName\":\"\\\"Mario Audelo\\\"\",\"orcid\":\"\\\"0000-0000-0000-0000\\\"\",\"accessUrl\":null}"]}'

        # --isInit \
        # -c '{"Args":[]}'

}
chaincodeInvoke2() {
    setGlobals $1

    # Create Car
    peer chaincode invoke -o localhost:${ORDERER0_PORT_GENERAL} \
        --ordererTLSHostnameOverride $ORDERER0_HOST \
        --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses localhost:${PEER0_ORG0_PORT_GENERAL} --tlsRootCertFiles $PEER0_ORG0_CA \
        --peerAddresses localhost:${PEER1_ORG0_PORT_GENERAL} --tlsRootCertFiles $PEER1_ORG0_CA \
        --peerAddresses localhost:${PEER2_ORG0_PORT_GENERAL} --tlsRootCertFiles $PEER2_ORG0_CA \
        --peerAddresses localhost:${PEER0_ORG1_PORT_GENERAL} --tlsRootCertFiles $PEER0_ORG1_CA \
        --peerAddresses localhost:${PEER1_ORG1_PORT_GENERAL} --tlsRootCertFiles $PEER1_ORG1_CA \
        --peerAddresses localhost:${PEER2_ORG1_PORT_GENERAL} --tlsRootCertFiles $PEER2_ORG1_CA \
        -c  '{"function": "CreateRecord","Args":["{\"Id\":\"S0_bga_10_77402_QGSII_flat_defaults_DAT210014\",\"type\":\"S0\",\"generationDate\":\"2021-04-16T10:53:09.711809Z\",\"metadata\":{\"hash\":\"e243c2c1c7ddb141fb5d6923c661f1bedde28f6dc8a91843cb128372f4c97a20\",\"location\":\"/S0_bga_10_77402_QGSII_flat_defaults/.metadata/.DAT210014.bz2.jsonld.20220701T110649.046679Z\"},\"rawData\":{\"hash\":\"8be1607a17068a658bad580dc167c13576a245217cdb771a5119d521dccc1db7\",\"location\":\"/S0_bga_10_77402_QGSII_flat_defaults/DAT210014.bz2\"},\"inputData\":{\"hash\":\"c418dc9e00a45b25b245ef010268c79b208d80f8ebe5ff1930a57f2e023dcafd\",\"location\":\"/S0_bga_10_77402_QGSII_flat_defaults/DAT210014-0014-00000000366.input\"},\"inputMetadata\":{\"hash\":\"598cb5eaff3ff6bb7b24fef9966c7e12777ad71c64382fa261a3b5e4af0a6632\",\"location\":\"/S0_bga_10_77402_QGSII_flat_defaults/.metadata/.DAT210014-0014-00000000366.input.jsonld.20220701T110644.615156Z\"},\"outputData\":{\"hash\":\"ec8512a206388d4560543484f1d94f7dc5e5b86e24d8f1cd0914f198e1b440da\",\"location\":\"/S0_bga_10_77402_QGSII_flat_defaults/DAT210014-0014-00000000366.lst.bz2\"},\"outputMetadata\":{\"hash\":\"b7815cf7b35626ba6300b6d6b6ed5f3f090c132810a78b045d1da7d1ae0b5fe4\",\"location\":\"/S0_bga_10_77402_QGSII_flat_defaults/.metadata/.DAT210014-0014-00000000366.lst.bz2.jsonld.20220701T110646.868333Z\"},\"siteName\":\"bga\",\"orcid\":\"https://orcid.org/0000-0001-6497-753X\",\"accessUrl\":[\"http://hdl.handle.net/21.12145/gi9Hc9c\",\"https://datahub.egi.eu/share/37b0a0d99cbae5791db93ababbef5b90chccda\"]}"]}' 

        # -c '{"Args":["CreateRecord","{\"ID\": \"ESPOCH_nogps_2016_05_20_01h00\", \"Type\": \"L0\", \"GenerationDate\": \"2016 05_20_01:00:00\", \"Metadata\": \"6825e7e22be44f11bdcfa2baf4a76e1b56cb8066bbc678833af466b79395899e\", \"Rawdata\": \"852b399e581132110d385d1a30e71cf7be74202043c9e430ba3843e538f65969\", \"inputData\": null, \"inputMetadata\": null, \"outputData\": null, \"outputMetadata\": null, \"SiteName\": \"\\\"Escuela Superior Polit\\u00e9cnica de Chimborazo\\\"\", \"collaboratorName\": \"\\\"Mario Audelo\\\"\", \"orcid\": \"\\\"0000-0000-0000-0000\\\"\", \"accessUrl\": null}"]}'

        # --isInit \
        # -c '{"Args":[]}'

}


# chaincodeInvoke 1

chaincodeQuery() {
    setGlobals 0 $PEER2_ORG0_PORT_GENERAL
    peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function": "GetAllRecords","Args":[]}'
}

# chaincodeQuery



# To execute everything
# presetup
# packageChaincode

# installChaincode

# queryInstalled 0
# approveForMyOrg 0
# checkCommitReadyness 0

# queryInstalled 1
# approveForMyOrg 1
# checkCommitReadyness 1


# commitChaincodeDefination 1
# chaincodeInvoke 1
# chaincodeInvoke2 1
chaincodeQuery