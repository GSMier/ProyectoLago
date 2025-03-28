
source ~/.env

NAME_USER_PRUEBA=prueba-user
PW_USER_PRUEBA=prueba-user-pw


registerAndEnrollUser(){
export FABRIC_CA_CLIENT_HOME=/home/gianm/ProyectoLago/channel/crypto-config/peerOrganizations/${ORG0_NAME}/
export FABRIC_CA_CLIENT_TLS_CERTFILES=/home/gianm/ProyectoLago/channel/certificates/fabric-ca/${ORG0_NAME}/tls-cert.pem
fabric-ca-client register --caname ca.${ORG0_NAME} --id.name ${NAME_USER_PRUEBA} --id.secret ${PW_USER_PRUEBA} --id.type client --id.attrs "role=collaborator:ecert"
mkdir -p /home/gianm/ProyectoLago/channel/crypto-config/peerOrganizations/${ORG0_NAME}/users/${NAME_USER_PRUEBA}
  echo "Generating MSP for user ${NAME_USER_PRUEBA}"
  fabric-ca-client enroll -u https://${NAME_USER_PRUEBA}:${PW_USER_PRUEBA}@localhost:${CA_ORG0_PORT} --caname ca.${ORG0_NAME} -M /home/gianm/ProyectoLago/channel/crypto-config/peerOrganizations/${ORG0_NAME}/users/${NAME_USER_PRUEBA}/msp --enrollment.attrs "role"
  cp /home/gianm/ProyectoLago/channel/crypto-config/peerOrganizations/${ORG0_NAME}/users/${NAME_USER_PRUEBA}/msp/keystore/* /home/gianm/ProyectoLago/channel/crypto-config/peerOrganizations/${ORG0_NAME}/users/${NAME_USER_PRUEBA}/msp/keystore/priv_sk



}



registerAndEnrollUser