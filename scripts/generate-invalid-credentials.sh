

createCA(){
docker run -d \
  --name ca-invalidca \
  -e FABRIC_CA_HOME=/etc/hyperledger/fabric-ca-server \
  -e FABRIC_CA_SERVER_CA_NAME=ca.invalidca \
  -e FABRIC_CA_SERVER_TLS_ENABLED=true \
  -e FABRIC_CA_SERVER_PORT=9100 \
  -p 9100:9100 \
  -v ./fabric-ca/invalidca:/etc/hyperledger/fabric-ca-server \
  hyperledger/fabric-ca \
  sh -c "fabric-ca-server start -b invalidca-user:invalidca-user-pw -d"

}

createCA
docker exec ca-invalidca chmod -R 777 /etc/hyperledger/fabric-ca-server

sleep 10
registerUser(){

NAME_USER_PRUEBA=prueba-user
PW_USER_PRUEBA=prueba-user-pw
ORG_NAME=invalidca

  mkdir -p ./fabric-ca/${ORG_NAME}/



export FABRIC_CA_CLIENT_HOME=./fabric-ca/invalidca/
export FABRIC_CA_CLIENT_TLS_CERTFILES=./tls-cert.pem
  fabric-ca-client enroll -u https://invalidca-user:invalidca-user-pw@localhost:9100 --caname ca.invalidca


fabric-ca-client register --caname ca.invalidca --id.name ${NAME_USER_PRUEBA} --id.secret ${PW_USER_PRUEBA} --id.type client --id.attrs "role=collaborator:ecert"
mkdir -p ./fabric-ca/${ORG_NAME}/users/${NAME_USER_PRUEBA}
  echo "Generating MSP for user ${NAME_USER_PRUEBA}"
  fabric-ca-client enroll -u https://${NAME_USER_PRUEBA}:${PW_USER_PRUEBA}@localhost:9100 --caname ca.${ORG_NAME} -M ./users/${NAME_USER_PRUEBA}/msp --enrollment.attrs "role"
  cp ./fabric-ca/${ORG_NAME}/users/${NAME_USER_PRUEBA}/msp/keystore/* ./fabric-ca/${ORG_NAME}/users/${NAME_USER_PRUEBA}/msp/keystore/priv_sk


}

registerUser