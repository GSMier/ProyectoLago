. utils.sh
source ~/.env


export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/../channel/crypto-config/ordererOrganizations/${ORG_ORDERER_NAME}/orderers/${ORDERER0_HOST}/msp/tlscacerts/tlsca.${ORG_ORDERER_NAME}-cert.pem
export PEER0_ORG0_CA=${PWD}/../channel/crypto-config/peerOrganizations/${ORG0_NAME}/peers/${PEER0_ORG0_NAME}/tls/ca.crt
export PEER1_ORG0_CA=${PWD}/../channel/crypto-config/peerOrganizations/${ORG0_NAME}/peers/${PEER1_ORG0_NAME}/tls/ca.crt
export PEER2_ORG0_CA=${PWD}/../channel/crypto-config/peerOrganizations/${ORG0_NAME}/peers/${PEER2_ORG0_NAME}/tls/ca.crt
export PEER0_ORG1_CA=${PWD}/../channel/crypto-config/peerOrganizations/${ORG1_NAME}/peers/${PEER0_ORG1_NAME}/tls/ca.crt
export PEER1_ORG1_CA=${PWD}/../channel/crypto-config/peerOrganizations/${ORG1_NAME}/peers/${PEER1_ORG1_NAME}/tls/ca.crt
export PEER2_ORG1_CA=${PWD}/../channel/crypto-config/peerOrganizations/${ORG1_NAME}/peers/${PEER2_ORG1_NAME}/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/../channel/config/

export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/../channel/crypto-config/ordererOrganizations/${ORG_ORDERER_NAME}/orderers/${ORDERER0_HOST}/tls/server.crt
export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/../channel/crypto-config/ordererOrganizations/${ORG_ORDERER_NAME}/orderers/${ORDERER0_HOST}/tls/server.key

export ORDERER2_ADMIN_TLS_SIGN_CERT=${PWD}/../channel/crypto-config/ordererOrganizations/${ORG_ORDERER_NAME}/orderers/${ORDERER1_HOST}/tls/server.crt
export ORDERER2_ADMIN_TLS_PRIVATE_KEY=${PWD}/../channel/crypto-config/ordererOrganizations/${ORG_ORDERER_NAME}/orderers/${ORDERER1_HOST}/tls/server.key

export ORDERER3_ADMIN_TLS_SIGN_CERT=${PWD}/../channel/crypto-config/ordererOrganizations/${ORG_ORDERER_NAME}/orderers/${ORDERER2_HOST}/tls/server.crt
export ORDERER3_ADMIN_TLS_PRIVATE_KEY=${PWD}/../channel/crypto-config/ordererOrganizations/${ORG_ORDERER_NAME}/orderers/${ORDERER2_HOST}/tls/server.key

# Set environment variables for the peer org
setGlobals() {
  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG=$OVERRIDE_ORG
  fi

  PEER_PORT=$2
  if [ $USING_ORG -eq 0 ] && [ -z "$PEER_PORT" ]; then
    PEER_PORT=$PEER0_ORG0_PORT_GENERAL
  elif [ $USING_ORG -eq 1 ] && [ -z "$PEER_PORT" ]; then
    PEER_PORT=$PEER0_ORG1_PORT_GENERAL
  fi
    
  

  infoln "Using organization ${USING_ORG}"
  infoln "Using Peer Port ${PEER_PORT}"
  if [ $USING_ORG -eq 0 ]; then
    export CORE_PEER_LOCALMSPID=$ORG0_MSPID
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG0_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/../channel/crypto-config/peerOrganizations/${ORG0_NAME}/users/${ADMIN_ORG0_NAME}/msp
    export CORE_PEER_ADDRESS=localhost:${PEER_PORT}
  elif [ $USING_ORG -eq 1 ]; then
    export CORE_PEER_LOCALMSPID=$ORG1_MSPID
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/../channel/crypto-config/peerOrganizations/${ORG1_NAME}/users/${ADMIN_ORG1_NAME}/msp
    export CORE_PEER_ADDRESS=localhost:${PEER_PORT}
  else
    errorln "ORG Unknown"
  fi

    if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
    fi
}
