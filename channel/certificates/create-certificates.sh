source ~/.env
createCertificatesTLSCA(){

  echo
  echo "Enroll the TLS CA admin"
  echo
  mkdir -p ../crypto-config/${TLS_CA_NAME}/admin
  export FABRIC_CA_CLIENT_HOME=${PWD}/../crypto-config/${TLS_CA_NAME}/admin
  export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/fabric-ca/${TLS_CA_NAME}/tls-cert.pem
  fabric-ca-client enroll -u https://${TLS_CA_USER}:${TLS_CA_PW}@localhost:${TLS_CA_PORT} --caname ${TLS_CA_NAME}


  registerPeersOrg(){
    PEER_TLS_ORG_USER=$1
    PEER_TLS_ORG_PW=$2

    echo
    echo "Register ${PEER_TLS_ORG_USER}"
    echo
    fabric-ca-client register --caname ${TLS_CA_NAME} --id.name ${PEER_TLS_ORG_USER} --id.secret ${PEER_TLS_ORG_PW} --id.type peer

  }
  registerPeersOrg $PEER0_TLS_ORG0_USER $PEER0_TLS_ORG0_PW
  registerPeersOrg $PEER1_TLS_ORG0_USER $PEER1_TLS_ORG0_PW
  registerPeersOrg $PEER2_TLS_ORG0_USER $PEER2_TLS_ORG0_PW


  registerPeersOrg $PEER0_TLS_ORG1_USER $PEER0_TLS_ORG1_PW
  registerPeersOrg $PEER1_TLS_ORG1_USER $PEER1_TLS_ORG1_PW
  registerPeersOrg $PEER2_TLS_ORG1_USER $PEER2_TLS_ORG1_PW

  echo "Register orderer0"
  echo
  fabric-ca-client register --caname ${TLS_CA_NAME} --id.name ${ORDERER0_TLS} --id.secret ${ORDERER0_PW_TLS} --id.type orderer
  echo
  echo "Register orderer1"
  echo
  fabric-ca-client register --caname ${TLS_CA_NAME} --id.name ${ORDERER1_TLS} --id.secret ${ORDERER1_PW_TLS} --id.type orderer
  echo
  echo "Register orderer2"
  echo
  fabric-ca-client register --caname ${TLS_CA_NAME} --id.name ${ORDERER2_TLS} --id.secret ${ORDERER2_PW_TLS} --id.type orderer
}


generateCertificatesForOrg() {
  ORG_NAME=$1
  CA_USER=$2
  CA_PW=$3
  CA_PORT=$4
  
  PEER0_NAME=$5
  PEER0_CA_USER=$6
  PEER0_CA_PW=$7
  PEER0_TLS_USER=$8
  PEER0_TLS_PW=$9
  
  PEER1_NAME=${10}
  PEER1_CA_USER=${11}
  PEER1_CA_PW=${12}
  PEER1_TLS_USER=${13}
  PEER1_TLS_PW=${14}
  
  PEER2_NAME=${15}
  PEER2_CA_USER=${16}
  PEER2_CA_PW=${17}
  PEER2_TLS_USER=${18}
  PEER2_TLS_PW=${19}
  
  TLS_CA_NAME=${20}
  TLS_CA_PORT=${21}
  
  PEER0_HOST=${22}
  PEER1_HOST=${23}
  PEER2_HOST=${24}

  echo "Enrolling CA admin for ${ORG_NAME}"
  mkdir -p ../crypto-config/peerOrganizations/${ORG_NAME}/
  export FABRIC_CA_CLIENT_HOME=${PWD}/../crypto-config/peerOrganizations/${ORG_NAME}/
  export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/fabric-ca/${ORG_NAME}/tls-cert.pem

  fabric-ca-client enroll -u https://${CA_USER}:${CA_PW}@localhost:${CA_PORT} --caname ca.${ORG_NAME}

  echo "NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-${CA_PORT}-ca-${ORG_NAME}.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-${CA_PORT}-ca-${ORG_NAME}.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-${CA_PORT}-ca-${ORG_NAME}.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-${CA_PORT}-ca-${ORG_NAME}.pem
    OrganizationalUnitIdentifier: orderer" >${PWD}/../crypto-config/peerOrganizations/${ORG_NAME}/msp/config.yaml

  # echo "Registering identities for ${ORG_NAME}"
  # fabric-ca-client register --caname ca.${ORG_NAME} --id.name ${PEER_CA_NAME} --id.secret ${PEER_CA_PW} --id.type peer
  # fabric-ca-client register --caname ca.${ORG_NAME} --id.name ${USER_CA_USER} --id.secret ${USER_CA_PW} --id.type client
  # fabric-ca-client register --caname ca.${ORG_NAME} --id.name ${ADMIN_CA_USER} --id.secret ${ADMIN_CA_PW} --id.type admin


 registerAndEnrollPeer(){
    export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/fabric-ca/${ORG_NAME}/tls-cert.pem
    PEER_NAME=$1
    PEER_CA_USER=$2
    PEER_CA_PW=$3
    PEER_TLS_USER=$4
    PEER_TLS_PWD=$5
    PEER_HOST=$6


    fabric-ca-client register --caname ca.${ORG_NAME} --id.name ${PEER_CA_USER} --id.secret ${PEER_CA_PW} --id.type peer \
      
    mkdir -p ../crypto-config/peerOrganizations/${ORG_NAME}/peers/${PEER_NAME}
    echo "Generating MSP for peer ${PEER_NAME} of ${ORG_NAME}"
    fabric-ca-client enroll -u https://${PEER_CA_USER}:${PEER_CA_PW}@localhost:${CA_PORT} --caname ca.${ORG_NAME} -M ${PWD}/../crypto-config/peerOrganizations/${ORG_NAME}/peers/${PEER_NAME}/msp --csr.hosts ${PEER_HOST}

    cp ${PWD}/../crypto-config/peerOrganizations/${ORG_NAME}/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/${ORG_NAME}/peers/${PEER_NAME}/msp/config.yaml

    echo "Generating TLS certificates for ${PEER_NAME}"
    export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/fabric-ca/${TLS_CA_NAME}/tls-cert.pem
    fabric-ca-client enroll -u https://${PEER_TLS_USER}:${PEER_TLS_PWD}@localhost:${TLS_CA_PORT} --caname ${TLS_CA_NAME} -M ${PWD}/../crypto-config/peerOrganizations/${ORG_NAME}/peers/${PEER_NAME}/tls --enrollment.profile tls --csr.hosts ${PEER_HOST} --csr.hosts localhost

    cp ${PWD}/../crypto-config/peerOrganizations/${ORG_NAME}/peers/${PEER_NAME}/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/${ORG_NAME}/peers/${PEER_NAME}/tls/ca.crt
    cp ${PWD}/../crypto-config/peerOrganizations/${ORG_NAME}/peers/${PEER_NAME}/tls/signcerts/* ${PWD}/../crypto-config/peerOrganizations/${ORG_NAME}/peers/${PEER_NAME}/tls/server.crt
    cp ${PWD}/../crypto-config/peerOrganizations/${ORG_NAME}/peers/${PEER_NAME}/tls/keystore/* ${PWD}/../crypto-config/peerOrganizations/${ORG_NAME}/peers/${PEER_NAME}/tls/server.key

    mkdir -p ${PWD}/../crypto-config/peerOrganizations/${ORG_NAME}/msp/tlscacerts
    cp ${PWD}/../crypto-config/peerOrganizations/${ORG_NAME}/peers/${PEER_NAME}/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/${ORG_NAME}/msp/tlscacerts/ca.crt

    mkdir ${PWD}/../crypto-config/peerOrganizations/${ORG_NAME}/tlsca
    cp ${PWD}/../crypto-config/peerOrganizations/${ORG_NAME}/peers/${PEER_NAME}/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/${ORG_NAME}/tlsca/tlsca.${ORG_NAME}-cert.pem

    mkdir ${PWD}/../crypto-config/peerOrganizations/${ORG_NAME}/ca
    cp ${PWD}/../crypto-config/peerOrganizations/${ORG_NAME}/peers/${PEER_NAME}/msp/cacerts/* ${PWD}/../crypto-config/peerOrganizations/${ORG_NAME}/ca/ca.${ORG_NAME}-cert.pem


 }
  
  registerAndEnrollPeer $PEER0_NAME $PEER0_CA_USER $PEER0_CA_PW $PEER0_TLS_USER $PEER0_TLS_PW $PEER0_HOST
  registerAndEnrollPeer $PEER1_NAME $PEER1_CA_USER $PEER1_CA_PW $PEER1_TLS_USER $PEER1_TLS_PW $PEER1_HOST
  registerAndEnrollPeer $PEER2_NAME $PEER2_CA_USER $PEER2_CA_PW $PEER2_TLS_USER $PEER2_TLS_PW $PEER2_HOST


  # export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/fabric-ca/${ORG_NAME}/tls-cert.pem


  # mkdir -p ${PWD}/../crypto-config/peerOrganizations/${ORG_NAME}/users/${USER_NAME}
  # echo "Generating MSP for user ${USER_NAME}"
  # fabric-ca-client enroll -u https://${USER_CA_USER}:${USER_CA_PW}@localhost:${CA_PORT} --caname ca.${ORG_NAME} -M ${PWD}/../crypto-config/peerOrganizations/${ORG_NAME}/users/${USER_NAME}/msp
  # cp ${PWD}/../crypto-config/peerOrganizations/${ORG_NAME}/users/${USER_NAME}/msp/keystore/* ${PWD}/../crypto-config/peerOrganizations/${ORG_NAME}/users/${USER_NAME}/msp/keystore/priv_sk

  # mkdir -p ../crypto-config/peerOrganizations/${ORG_NAME}/users/${ADMIN_NAME}
  # echo "Generating MSP for admin ${ADMIN_NAME}"
  # fabric-ca-client enroll -u https://${ADMIN_CA_USER}:${ADMIN_CA_PW}@localhost:${CA_PORT} --caname ca.${ORG_NAME} -M ${PWD}/../crypto-config/peerOrganizations/${ORG_NAME}/users/${ADMIN_NAME}/msp
  # cp ${PWD}/../crypto-config/peerOrganizations/${ORG_NAME}/users/${ADMIN_NAME}/msp/keystore/* ${PWD}/../crypto-config/peerOrganizations/${ORG_NAME}/users/${ADMIN_NAME}/msp/keystore/priv_sk
  # cp ${PWD}/../crypto-config/peerOrganizations/${ORG_NAME}/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/${ORG_NAME}/users/${ADMIN_NAME}/msp/config.yaml
}

generateCertificatesForUser(){
  export FABRIC_CA_CLIENT_HOME=${PWD}/../crypto-config/peerOrganizations/${ORG0_NAME}/
  export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/fabric-ca/${ORG0_NAME}/tls-cert.pem

  fabric-ca-client register --caname ca.${ORG0_NAME} --id.name ${USER0_CA_ORG0_USER} --id.secret ${USER0_CA_ORG0_PW} --id.type client --id.attrs "role=viewer:ecert"
  fabric-ca-client register --caname ca.${ORG0_NAME} --id.name ${USER1_CA_ORG0_USER} --id.secret ${USER1_CA_ORG0_PW} --id.type client --id.attrs "role=collaborator:ecert"
  fabric-ca-client register --caname ca.${ORG0_NAME} --id.name ${USER2_CA_ORG0_USER} --id.secret ${USER2_CA_ORG0_PW} --id.type client --id.attrs "role=collaborator:ecert"
  fabric-ca-client register --caname ca.${ORG0_NAME} --id.name ${ADMIN0_CA_ORG0_USER} --id.secret ${ADMIN0_CA_ORG0_PW} --id.type admin

  export FABRIC_CA_CLIENT_HOME=${PWD}/../crypto-config/peerOrganizations/${ORG1_NAME}/
  export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/fabric-ca/${ORG1_NAME}/tls-cert.pem

  fabric-ca-client register --caname ca.${ORG1_NAME} --id.name ${USER0_CA_ORG1_USER} --id.secret ${USER0_CA_ORG1_PW} --id.type client --id.attrs "role=viewer:ecert"
  fabric-ca-client register --caname ca.${ORG1_NAME} --id.name ${USER1_CA_ORG1_USER} --id.secret ${USER1_CA_ORG1_PW} --id.type client --id.attrs "role=collaborator:ecert"
  fabric-ca-client register --caname ca.${ORG1_NAME} --id.name ${ADMIN0_CA_ORG1_USER} --id.secret ${ADMIN0_CA_ORG1_PW} --id.type admin

  export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/fabric-ca/${ORG0_NAME}/tls-cert.pem

  mkdir -p ${PWD}/../crypto-config/peerOrganizations/${ORG0_NAME}/users/${USER0_ORG0_NAME}
  echo "Generating MSP for user ${USER0_ORG0_NAME}"
  fabric-ca-client enroll -u https://${USER0_CA_ORG0_USER}:${USER0_CA_ORG0_PW}@localhost:${CA_ORG0_PORT} --caname ca.${ORG0_NAME} -M ${PWD}/../crypto-config/peerOrganizations/${ORG0_NAME}/users/${USER0_ORG0_NAME}/msp --enrollment.attrs "role"
  cp ${PWD}/../crypto-config/peerOrganizations/${ORG0_NAME}/users/${USER0_ORG0_NAME}/msp/keystore/* ${PWD}/../crypto-config/peerOrganizations/${ORG0_NAME}/users/${USER0_ORG0_NAME}/msp/keystore/priv_sk


  mkdir -p ${PWD}/../crypto-config/peerOrganizations/${ORG0_NAME}/users/${USER1_ORG0_NAME}
  echo "Generating MSP for user ${USER1_ORG0_NAME}"
  fabric-ca-client enroll -u https://${USER1_CA_ORG0_USER}:${USER1_CA_ORG0_PW}@localhost:${CA_ORG0_PORT} --caname ca.${ORG0_NAME} -M ${PWD}/../crypto-config/peerOrganizations/${ORG0_NAME}/users/${USER1_ORG0_NAME}/msp --enrollment.attrs "role"
  cp ${PWD}/../crypto-config/peerOrganizations/${ORG0_NAME}/users/${USER1_ORG0_NAME}/msp/keystore/* ${PWD}/../crypto-config/peerOrganizations/${ORG0_NAME}/users/${USER1_ORG0_NAME}/msp/keystore/priv_sk

  mkdir -p ${PWD}/../crypto-config/peerOrganizations/${ORG0_NAME}/users/${USER2_ORG0_NAME}
  echo "Generating MSP for user ${USER2_ORG0_NAME}"
  fabric-ca-client enroll -u https://${USER2_CA_ORG0_USER}:${USER2_CA_ORG0_PW}@localhost:${CA_ORG0_PORT} --caname ca.${ORG0_NAME} -M ${PWD}/../crypto-config/peerOrganizations/${ORG0_NAME}/users/${USER2_ORG0_NAME}/msp --enrollment.attrs "role"
  cp ${PWD}/../crypto-config/peerOrganizations/${ORG0_NAME}/users/${USER2_ORG0_NAME}/msp/keystore/* ${PWD}/../crypto-config/peerOrganizations/${ORG0_NAME}/users/${USER2_ORG0_NAME}/msp/keystore/priv_sk

  mkdir -p ../crypto-config/peerOrganizations/${ORG0_NAME}/users/${ADMIN_ORG0_NAME}
  echo "Generating MSP for admin ${ADMIN_ORG0_NAME}"
  fabric-ca-client enroll -u https://${ADMIN0_CA_ORG0_USER}:${ADMIN0_CA_ORG0_PW}@localhost:${CA_ORG0_PORT} --caname ca.${ORG0_NAME} -M ${PWD}/../crypto-config/peerOrganizations/${ORG0_NAME}/users/${ADMIN_ORG0_NAME}/msp
  cp ${PWD}/../crypto-config/peerOrganizations/${ORG0_NAME}/users/${ADMIN_ORG0_NAME}/msp/keystore/* ${PWD}/../crypto-config/peerOrganizations/${ORG0_NAME}/users/${ADMIN_ORG0_NAME}/msp/keystore/priv_sk
  cp ${PWD}/../crypto-config/peerOrganizations/${ORG0_NAME}/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/${ORG0_NAME}/users/${ADMIN_ORG0_NAME}/msp/config.yaml



  
  export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/fabric-ca/${ORG1_NAME}/tls-cert.pem

  mkdir -p ${PWD}/../crypto-config/peerOrganizations/${ORG1_NAME}/users/${USER0_ORG1_NAME}
  echo "Generating MSP for user ${USER0_ORG1_NAME}"
  fabric-ca-client enroll -u https://${USER0_CA_ORG1_USER}:${USER0_CA_ORG1_PW}@localhost:${CA_ORG1_PORT} --caname ca.${ORG1_NAME} -M ${PWD}/../crypto-config/peerOrganizations/${ORG1_NAME}/users/${USER0_ORG1_NAME}/msp --enrollment.attrs "role"
  cp ${PWD}/../crypto-config/peerOrganizations/${ORG1_NAME}/users/${USER0_ORG1_NAME}/msp/keystore/* ${PWD}/../crypto-config/peerOrganizations/${ORG1_NAME}/users/${USER0_ORG1_NAME}/msp/keystore/priv_sk


  mkdir -p ${PWD}/../crypto-config/peerOrganizations/${ORG1_NAME}/users/${USER1_ORG1_NAME}
  echo "Generating MSP for user ${USER1_ORG1_NAME}"
  fabric-ca-client enroll -u https://${USER1_CA_ORG1_USER}:${USER1_CA_ORG1_PW}@localhost:${CA_ORG1_PORT} --caname ca.${ORG1_NAME} -M ${PWD}/../crypto-config/peerOrganizations/${ORG1_NAME}/users/${USER1_ORG1_NAME}/msp --enrollment.attrs "role"
  cp ${PWD}/../crypto-config/peerOrganizations/${ORG1_NAME}/users/${USER1_ORG1_NAME}/msp/keystore/* ${PWD}/../crypto-config/peerOrganizations/${ORG1_NAME}/users/${USER1_ORG1_NAME}/msp/keystore/priv_sk


  mkdir -p ../crypto-config/peerOrganizations/${ORG1_NAME}/users/${ADMIN_ORG1_NAME}
  echo "Generating MSP for admin ${ADMIN_ORG1_NAME}"
  fabric-ca-client enroll -u https://${ADMIN0_CA_ORG1_USER}:${ADMIN0_CA_ORG1_PW}@localhost:${CA_ORG1_PORT} --caname ca.${ORG1_NAME} -M ${PWD}/../crypto-config/peerOrganizations/${ORG1_NAME}/users/${ADMIN_ORG1_NAME}/msp
  cp ${PWD}/../crypto-config/peerOrganizations/${ORG1_NAME}/users/${ADMIN_ORG1_NAME}/msp/keystore/* ${PWD}/../crypto-config/peerOrganizations/${ORG1_NAME}/users/${ADMIN_ORG1_NAME}/msp/keystore/priv_sk
  cp ${PWD}/../crypto-config/peerOrganizations/${ORG1_NAME}/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/${ORG1_NAME}/users/${ADMIN_ORG1_NAME}/msp/config.yaml

}



createCertificatesForOrderer() {
  echo
  echo "Enroll the CA admin for orderer"
  echo

  # Set up directories and environment variables
  mkdir -p ${PWD}/../crypto-config/ordererOrganizations/${ORG_ORDERER_NAME}
  export FABRIC_CA_CLIENT_HOME=${PWD}/../crypto-config/ordererOrganizations/${ORG_ORDERER_NAME}
  export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/fabric-ca/${ORG_ORDERER_NAME}/tls-cert.pem


  # Enroll the orderer CA admin
  fabric-ca-client enroll -u https://${CA_ORDERER_USER}:${CA_ORDERER_PW}@localhost:${CA_ORDERER_PORT} \
    --caname ca.${ORG_ORDERER_NAME}

  # Create config.yaml for NodeOUs
  echo "NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-${CA_ORDERER_PORT}-ca-${ORG_ORDERER_NAME}.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-${CA_ORDERER_PORT}-ca-${ORG_ORDERER_NAME}.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-${CA_ORDERER_PORT}-ca-${ORG_ORDERER_NAME}.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-${CA_ORDERER_PORT}-ca-${ORG_ORDERER_NAME}.pem
    OrganizationalUnitIdentifier: orderer" > ${PWD}/../crypto-config/ordererOrganizations/${ORG_ORDERER_NAME}/msp/config.yaml

  echo
  echo "Register orderer identities"
  echo

  # Register orderers and admin

  registerOrderer(){
      ORDERER_CA_USER=$1
      ORDERER_CA_PW=$2

      fabric-ca-client register --caname ca.${ORG_ORDERER_NAME} --id.name ${ORDERER_CA_USER} --id.secret ${ORDERER_CA_PW} --id.type orderer \
      
  }

  registerOrderer $ORDERER0_CA_USER $ORDERER0_CA_PW
  registerOrderer $ORDERER1_CA_USER $ORDERER1_CA_PW
  registerOrderer $ORDERER2_CA_USER $ORDERER2_CA_PW


  # Function to enroll MSP and TLS for each orderer
  enrollOrderer() {
    ORDERER_NAME=$1
    ORDERER_CA_USER=$2
    ORDERER_CA_PW=$3
    ORDERER_TLS=$4
    ORDERER_PW_TLS=$5

    export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/fabric-ca/${ORG_ORDERER_NAME}/tls-cert.pem

    mkdir -p ${PWD}/../crypto-config/ordererOrganizations/${ORG_ORDERER_NAME}/orderers/${ORDERER_NAME}

    echo "## Generate the MSP for ${ORDERER_NAME}"
    fabric-ca-client enroll -u https://${ORDERER_CA_USER}:${ORDERER_CA_PW}@localhost:${CA_ORDERER_PORT} --caname ca.${ORG_ORDERER_NAME} \
      -M ${PWD}/../crypto-config/ordererOrganizations/${ORG_ORDERER_NAME}/orderers/${ORDERER_NAME}/msp \
      --csr.hosts ${ORDERER_NAME} --csr.hosts localhost

    cp ${PWD}/../crypto-config/ordererOrganizations/${ORG_ORDERER_NAME}/msp/config.yaml \
      ${PWD}/../crypto-config/ordererOrganizations/${ORG_ORDERER_NAME}/orderers/${ORDERER_NAME}/msp/config.yaml

    export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/fabric-ca/${TLS_CA_NAME}/tls-cert.pem


    echo "## Generate the TLS certificates for ${ORDERER_NAME}"
    fabric-ca-client enroll -u https://${ORDERER_TLS}:${ORDERER_PW_TLS}@localhost:${TLS_CA_PORT} --caname ${TLS_CA_NAME} \
      -M ${PWD}/../crypto-config/ordererOrganizations/${ORG_ORDERER_NAME}/orderers/${ORDERER_NAME}/tls \
      --enrollment.profile tls --csr.hosts ${ORDERER_NAME} --csr.hosts localhost \
      

    cp ${PWD}/../crypto-config/ordererOrganizations/${ORG_ORDERER_NAME}/orderers/${ORDERER_NAME}/tls/tlscacerts/* \
      ${PWD}/../crypto-config/ordererOrganizations/${ORG_ORDERER_NAME}/orderers/${ORDERER_NAME}/tls/ca.crt
    cp ${PWD}/../crypto-config/ordererOrganizations/${ORG_ORDERER_NAME}/orderers/${ORDERER_NAME}/tls/signcerts/* \
      ${PWD}/../crypto-config/ordererOrganizations/${ORG_ORDERER_NAME}/orderers/${ORDERER_NAME}/tls/server.crt
    cp ${PWD}/../crypto-config/ordererOrganizations/${ORG_ORDERER_NAME}/orderers/${ORDERER_NAME}/tls/keystore/* \
      ${PWD}/../crypto-config/ordererOrganizations/${ORG_ORDERER_NAME}/orderers/${ORDERER_NAME}/tls/server.key


    mkdir ${PWD}/../crypto-config/ordererOrganizations/${ORG_ORDERER_NAME}/orderers/${ORDERER_NAME}/msp/tlscacerts
      cp ${PWD}/../crypto-config/ordererOrganizations/${ORG_ORDERER_NAME}/orderers/${ORDERER_NAME}/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/${ORG_ORDERER_NAME}/orderers/${ORDERER_NAME}/msp/tlscacerts/tlsca.${ORG_ORDERER_NAME}-cert.pem


    mkdir ${PWD}/../crypto-config/ordererOrganizations/${ORG_ORDERER_NAME}/msp/tlscacerts
    cp ${PWD}/../crypto-config/ordererOrganizations/${ORG_ORDERER_NAME}/orderers/${ORDERER_NAME}/tls/tlscacerts/* \
      ${PWD}/../crypto-config/ordererOrganizations/${ORG_ORDERER_NAME}/msp/tlscacerts/tlsca.${ORG_ORDERER_NAME}-cert.pem
    
  }

  # Enroll MSP and TLS for each orderer
  enrollOrderer $ORDERER0_HOST $ORDERER0_CA_USER $ORDERER0_CA_PW $ORDERER0_TLS $ORDERER0_PW_TLS
  enrollOrderer $ORDERER1_HOST $ORDERER1_CA_USER $ORDERER1_CA_PW $ORDERER1_TLS $ORDERER1_PW_TLS
  enrollOrderer $ORDERER2_HOST $ORDERER2_CA_USER $ORDERER2_CA_PW $ORDERER2_TLS $ORDERER2_PW_TLS



  export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/fabric-ca/${ORG_ORDERER_NAME}/tls-cert.pem

  echo
  echo "Register the org admin for OrdererOrg"
  echo
  fabric-ca-client register --caname ca.${ORG_ORDERER_NAME} --id.name ${ADMIN_CA_ORDORG_USER} --id.secret ${ADMIN_CA_ORDORG_PW} --id.type admin 

  echo
  echo "Enrolling the orderer admin"
  echo
  # Enroll the admin MSP
  mkdir -p ${PWD}/../crypto-config/ordererOrganizations/${ORG_ORDERER_NAME}/users/${ADMIN_ORDORG_NAME}
  fabric-ca-client enroll -u https://${ADMIN_CA_ORDORG_USER}:${ADMIN_CA_ORDORG_PW}@localhost:${CA_ORDERER_PORT} --caname ca.${ORG_ORDERER_NAME} \
    -M ${PWD}/../crypto-config/ordererOrganizations/${ORG_ORDERER_NAME}/users/${ADMIN_ORDORG_NAME}/msp \
  

  cp ${PWD}/../crypto-config/ordererOrganizations/${ORG_ORDERER_NAME}/msp/config.yaml \
    ${PWD}/../crypto-config/ordererOrganizations/${ORG_ORDERER_NAME}/users/${ADMIN_ORDORG_NAME}/msp/config.yaml
}





removeCryptoMaterial(){
    rm -rf ${PWD}/../crypto-config
    rm -rf ./fabric-ca
}


# removeCryptoMaterial

createCertificatesTLSCA

# generateCertificatesForOrg $ORG0_NAME $CA_ORG0_USER $CA_ORG0_PW $CA_ORG0_PORT \
# $PEER0_ORG0_NAME $PEERO_CA_ORG0_USER $PEER0_CA_ORG0_PW $PEER0_TLS_ORG0_USER $PEER0_TLS_ORG0_PW \
# $PEER1_ORG0_NAME $PEER1_CA_ORG0_USER $PEER1_CA_ORG0_PW $PEER1_TLS_ORG0_USER $PEER1_TLS_ORG0_PW \
# $PEER2_ORG0_NAME $PEER2_CA_ORG0_USER $PEER2_CA_ORG0_PW $PEER2_TLS_ORG0_USER $PEER2_TLS_ORG0_PW \
# $USER0_ORG0_NAME $USER0_CA_ORG0_USER $USER0_CA_ORG0_PW \
# $ADMIN_ORG0_NAME $ADMIN0_CA_ORG0_USER $ADMIN0_CA_ORG0_PW \
# $TLS_CA_NAME $TLS_CA_PORT \
# $PEER0_ORG0_HOST $PEER1_ORG0_HOST $PEER2_ORG0_HOST 

generateCertificatesForOrg $ORG0_NAME $CA_ORG0_USER $CA_ORG0_PW $CA_ORG0_PORT $PEER0_ORG0_NAME $PEER0_CA_ORG0_USER $PEER0_CA_ORG0_PW $PEER0_TLS_ORG0_USER $PEER0_TLS_ORG0_PW $PEER1_ORG0_NAME $PEER1_CA_ORG0_USER $PEER1_CA_ORG0_PW $PEER1_TLS_ORG0_USER $PEER1_TLS_ORG0_PW $PEER2_ORG0_NAME $PEER2_CA_ORG0_USER $PEER2_CA_ORG0_PW $PEER2_TLS_ORG0_USER $PEER2_TLS_ORG0_PW  $TLS_CA_NAME $TLS_CA_PORT $PEER0_ORG0_HOST $PEER1_ORG0_HOST $PEER2_ORG0_HOST 
generateCertificatesForOrg $ORG1_NAME $CA_ORG1_USER $CA_ORG1_PW $CA_ORG1_PORT $PEER0_ORG1_NAME $PEER0_CA_ORG1_USER $PEER0_CA_ORG1_PW $PEER0_TLS_ORG1_USER $PEER0_TLS_ORG1_PW $PEER1_ORG1_NAME $PEER1_CA_ORG1_USER $PEER1_CA_ORG1_PW $PEER1_TLS_ORG1_USER $PEER1_TLS_ORG1_PW $PEER2_ORG1_NAME $PEER2_CA_ORG1_USER $PEER2_CA_ORG1_PW $PEER2_TLS_ORG1_USER $PEER2_TLS_ORG1_PW  $TLS_CA_NAME $TLS_CA_PORT $PEER0_ORG1_HOST $PEER1_ORG1_HOST $PEER2_ORG1_HOST
generateCertificatesForUser
createCertificatesForOrderer