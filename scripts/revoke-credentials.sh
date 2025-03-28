. utils.sh
. env-var.sh
source ~/.env

export FABRIC_CA_CLIENT_HOME=/home/gianm/ProyectoLago/channel/crypto-config/peerOrganizations/uis
export FABRIC_CA_CLIENT_TLS_CERTFILES=/home/gianm/ProyectoLago/channel/certificates/fabric-ca/uis/tls-cert.pem

CERT=/home/gianm/ProyectoLago/channel/crypto-config/peerOrganizations/uis/users/A.J.Rubio-Montero/msp/signcerts/cert.pem
serial=$(openssl x509 -in $CERT -serial -noout | cut -d "=" -f 2)
aki=$(openssl x509 -in $CERT -noout -text | awk '/Authority Key Identifier/ {getline; print $0}')
CHANNEL_NAME="lagochannel"

fabric-ca-client revoke -s $serial -a $aki -M ./msp --gencrl
# fabric-ca-client identity list
# fabric-ca-client revoke -e ${USER2_ORG0_NAME} -M  ./msp --caname "ca.${ORG0_NAME}" --gencrl
# fabric-ca-client gencrl -M ./msp
# cat /root/blockchain/channel/crypto-config/peerOrganizations/uis/msp/crls/crl.pem | base64 -w 0 > user_cert_base64
revokeFromFabricNetwork() {
    setGlobals 0

    set -x
    peer channel fetch config config_block.pb -o localhost:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
    set +x

    configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json
    jq '.data.data[0].payload.data.config' config_block.json > config.json

    # Add new CRL entry
    jq -a --arg new "$(cat user_cert_base64)" '.channel_group.groups.Application.groups.UISMSP.values.MSP.value.config.revocation_list += [$new]' config.json > modified_config.json

    configtxlator proto_encode --input config.json --type common.Config --output config.pb
    configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
    configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated modified_config.pb --output crl_update.pb

    configtxlator proto_decode --input crl_update.pb --type common.ConfigUpdate --output crl_update.json
    echo '{"payload":{"header":{"channel_header":{"channel_id":"lagochannel", "type":2}},"data":{"config_update":'$(cat crl_update.json)'}}}' | jq . > crl_update_in_envelope.json

    configtxlator proto_encode --input crl_update_in_envelope.json --type common.Envelope --output crl_update_in_envelope.pb

    peer channel update -f crl_update_in_envelope.pb -c $CHANNEL_NAME -o localhost:7050 --tls --cafile $ORDERER_CA
}
revokeFromFabricNetwork