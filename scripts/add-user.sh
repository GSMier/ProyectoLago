
source ~/.env

NAME_USER_PRUEBA1=prueba-user1
PW_USER_PRUEBA1=prueba-user-pw1


NAME_USER_PRUEBA2=prueba-user-2
PW_USER_PRUEBA2=prueba


registerAndEnrollUserPruebaColaborador(){
export FABRIC_CA_CLIENT_HOME=/home/gianm/ProyectoLago/channel/crypto-config/peerOrganizations/${ORG0_NAME}/
export FABRIC_CA_CLIENT_TLS_CERTFILES=/home/gianm/ProyectoLago/channel/certificates/fabric-ca/${ORG0_NAME}/tls-cert.pem
fabric-ca-client register --caname ca.${ORG0_NAME} --id.name ${NAME_USER_PRUEBA1} --id.secret ${PW_USER_PRUEBA1} --id.type client --id.attrs "role=collaborator:ecert"
mkdir -p /home/gianm/ProyectoLago/channel/crypto-config/peerOrganizations/${ORG0_NAME}/users/${NAME_USER_PRUEBA1}
  echo "Generating MSP for user ${NAME_USER_PRUEBA1}"
  fabric-ca-client enroll -u https://${NAME_USER_PRUEBA1}:${PW_USER_PRUEBA1}@localhost:${CA_ORG0_PORT} --caname ca.${ORG0_NAME} -M /home/gianm/ProyectoLago/channel/crypto-config/peerOrganizations/${ORG0_NAME}/users/${NAME_USER_PRUEBA1}/msp --enrollment.attrs "role"
  cp /home/gianm/ProyectoLago/channel/crypto-config/peerOrganizations/${ORG0_NAME}/users/${NAME_USER_PRUEBA1}/msp/keystore/* /home/gianm/ProyectoLago/channel/crypto-config/peerOrganizations/${ORG0_NAME}/users/${NAME_USER_PRUEBA1}/msp/keystore/priv_sk



}
registerAndEnrollUserPruebaViewer(){
export FABRIC_CA_CLIENT_HOME=/home/gianm/ProyectoLago/channel/crypto-config/peerOrganizations/${ORG0_NAME}/
export FABRIC_CA_CLIENT_TLS_CERTFILES=/home/gianm/ProyectoLago/channel/certificates/fabric-ca/${ORG0_NAME}/tls-cert.pem
fabric-ca-client register --caname ca.${ORG0_NAME} --id.name ${NAME_USER_PRUEBA2} --id.secret ${PW_USER_PRUEBA2} --id.type client --id.attrs "role=viewer:ecert"
mkdir -p /home/gianm/ProyectoLago/channel/crypto-config/peerOrganizations/${ORG0_NAME}/users/${NAME_USER_PRUEBA2}
  echo "Generating MSP for user ${NAME_USER_PRUEBA2}"
  fabric-ca-client enroll -u https://${NAME_USER_PRUEBA2}:${PW_USER_PRUEBA2}@localhost:${CA_ORG0_PORT} --caname ca.${ORG0_NAME} -M /home/gianm/ProyectoLago/channel/crypto-config/peerOrganizations/${ORG0_NAME}/users/${NAME_USER_PRUEBA2}/msp --enrollment.attrs "role"
  cp /home/gianm/ProyectoLago/channel/crypto-config/peerOrganizations/${ORG0_NAME}/users/${NAME_USER_PRUEBA2}/msp/keystore/* /home/gianm/ProyectoLago/channel/crypto-config/peerOrganizations/${ORG0_NAME}/users/${NAME_USER_PRUEBA2}/msp/keystore/priv_sk



}



registerAndEnrollUserPruebaColaborador

registerAndEnrollUserPruebaViewer
