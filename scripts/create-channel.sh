. utils.sh
. env-var.sh
source ~/.env

CHANNEL_NAME='lagochannel'

createChannel(){
    setGlobals 0
    osnadmin channel join --channelID $CHANNEL_NAME \
    --config-block ../artifacts/${CHANNEL_NAME}.block -o localhost:${ORDERER0_PORT_ADMIN} \
    --ca-file $ORDERER_CA \
    --client-cert $ORDERER_ADMIN_TLS_SIGN_CERT \
    --client-key $ORDERER_ADMIN_TLS_PRIVATE_KEY

    setGlobals 0
    osnadmin channel join --channelID $CHANNEL_NAME \
    --config-block ../artifacts/${CHANNEL_NAME}.block -o localhost:${ORDERER1_PORT_ADMIN} \
    --ca-file $ORDERER_CA \
    --client-cert $ORDERER2_ADMIN_TLS_SIGN_CERT \
    --client-key $ORDERER2_ADMIN_TLS_PRIVATE_KEY

    setGlobals 0
    osnadmin channel join --channelID $CHANNEL_NAME \
    --config-block ../artifacts/${CHANNEL_NAME}.block -o localhost:${ORDERER2_PORT_ADMIN} \
    --ca-file $ORDERER_CA \
    --client-cert $ORDERER3_ADMIN_TLS_SIGN_CERT \
    --client-key $ORDERER3_ADMIN_TLS_PRIVATE_KEY

}

createChannel

joinChannel(){
    FABRIC_CFG_PATH=$PWD/../channel/config

    setGlobals 0 $PEER0_ORG0_PORT_GENERAL
    peer channel join -b ../artifacts/${CHANNEL_NAME}.block
    setGlobals 0 $PEER1_ORG0_PORT_GENERAL
    peer channel join -b ../artifacts/${CHANNEL_NAME}.block
    setGlobals 0 $PEER2_ORG0_PORT_GENERAL
    peer channel join -b ../artifacts/${CHANNEL_NAME}.block

    setGlobals 1 $PEER0_ORG1_PORT_GENERAL
    peer channel join -b ../artifacts/${CHANNEL_NAME}.block
    setGlobals 1 $PEER1_ORG1_PORT_GENERAL
    peer channel join -b ../artifacts/${CHANNEL_NAME}.block
    setGlobals 1 $PEER2_ORG1_PORT_GENERAL
    peer channel join -b ../artifacts/${CHANNEL_NAME}.block

}

joinChannel
