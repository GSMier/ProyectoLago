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
        -c  '{"function": "CreateRecord","Args":["{\"Id\":\"S0_bga_10_77402_QGSII_flat_defaults_DAT000703\",\"type\":\"S0\",\"generationDate\":\"2021-04-16T10:51:59.484880Z\",\"metadata\":{\"hash\":\"0d306e78140af8100682db4a6a9493152a492b5845e663df8625320a372cf246\",\"location\":\"/S0_bga_10_77402_QGSII_flat_defaults/.metadata/.DAT000703.bz2.jsonld.20220701T110100.291889Z\"},\"rawData\":{\"hash\":\"d02d21a138f4ca5eb2cf23873c45e0cd2b6bada836155616206ce3bbb77e3026\",\"location\":\"/S0_bga_10_77402_QGSII_flat_defaults/DAT000703.bz2\"},\"inputData\":{\"hash\":\"47e8ceb1d194c19708cf7953560ef4301b752e5f3eb7c5962afa5b473553fc46\",\"location\":\"/S0_bga_10_77402_QGSII_flat_defaults/DAT000703-0703-00000000024.input\"},\"inputMetadata\":{\"hash\":\"30be9443fdcf95c935ae9401bf34d3e4fe947d33b693e0ae8807c7e9a2e3b934\",\"location\":\"/S0_bga_10_77402_QGSII_flat_defaults/.metadata/.DAT000703-0703-00000000024.input.jsonld.20220701T110055.716745Z\"},\"outputData\":{\"hash\":\"c5c1ac3c1d2dd730d72836354024a7cbdbe05c80ca605b150884f98bb0b550d0\",\"location\":\"/S0_bga_10_77402_QGSII_flat_defaults/DAT000703-0703-00000000024.lst.bz2\"},\"outputMetadata\":{\"hash\":\"b4540c82a72d2413a9ee7366ba6a3a5034d9dad230c0ef8e8d8f018b1e2934bc\",\"location\":\"/S0_bga_10_77402_QGSII_flat_defaults/.metadata/.DAT000703-0703-00000000024.lst.bz2.jsonld.20220701T110057.934361Z\"},\"siteName\":\"bga\",\"orcid\":\"https://orcid.org/0000-0001-6497-753X\",\"accessUrl\":[\"http://hdl.handle.net/21.12145/gi9Hc9c\",\"https://datahub.egi.eu/share/37b0a0d99cbae5791db93ababbef5b90chccda\"]}"
]}' 
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
        -c  '{"function": "CreateRecord","Args":["{\"Id\":\"S1_bga_60_77402_QGSII_flat_defaults_002010\",\"type\":\"S1\",\"generationDate\":\"2022-10-20T09:24:19.977221Z\",\"metadata\":{\"primary\":{\"hash\":\"85dec53ed1cb67e51053520dff6a3e9b5378ccaf357550d71407389b60c87111\",\"location\":\"/S1_bga_60_77402_QGSII_flat_defaults/.metadata/.002010.pri.bz2.jsonld\"},\"secondary\":{\"hash\":\"04382503d4532fe178a9421464ebf606a1f0995ce6816e68bb9c8a505eb55f39\",\"location\":\"/S1_bga_60_77402_QGSII_flat_defaults/.metadata/.002010.sec.bz2.jsonld\"}},\"rawData\":{\"primary\":{\"hash\":\"a8a73aa2be35267d8c7ab8cb70124de947fb72285cf48f979a4682fbfb94273f\",\"location\":\"/S1_bga_60_77402_QGSII_flat_defaults/002010.pri.bz2\"},\"secondary\":{\"hash\":\"cc48ac7c3f27cf1dbc67cae7d32e4948af7867068a3aa6597730a3ec32d335e3\",\"location\":\"/S1_bga_60_77402_QGSII_flat_defaults/002010.sec.bz2\"}},\"siteName\":\"bga\",\"orcid\":\"https://orcid.org/0000-0002-4559-8785\",\"accessUrl\":\"https://datahub.egi.eu/not_published_yet\"}"]}' 

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
presetup
packageChaincode

installChaincode

queryInstalled 0
approveForMyOrg 0
checkCommitReadyness 0

queryInstalled 1
approveForMyOrg 1
checkCommitReadyness 1


commitChaincodeDefination 1
chaincodeInvoke 1
chaincodeInvoke2 1
chaincodeQuery