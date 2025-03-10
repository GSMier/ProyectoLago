
source ~/.env
# Define the path to the folder containing the JSON files

readJsonFilesFromFolder(){

FOLDER_PATH=$1
# Check if the folder exists
if [ ! -d "$FOLDER_PATH" ]; then
    echo "Folder not found at ${FOLDER_PATH}"
    exit 1
fi

# Loop through all JSON files in the folder
for FILE in "$FOLDER_PATH"/*.json; do
    if [ -f "$FILE" ]; then
        echo "Processing file: $FILE"
        # Extract the name of the JSON file without the extension
        FILE_NAME=$(basename "$FILE" )

        # Add your file processing logic here
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
            sebstiian/lagochain-app \
            sh -c "npm start create /var/data/${FILE_NAME}"
            # --env FOLDER_PATH=/var/data \
            # --env JSONFILE=/var/data/${FILE_NAME} \

    fi
done

echo "All JSON files processed."
}

readJsonFilesFromFolder /home/gianm/LAGO-data/simulaciones/S0/S0_bga_10_77402_QGSII_flat_defaults/output
readJsonFilesFromFolder /home/gianm/LAGO-data/simulaciones/S1/S1_bga_60_77402_QGSII_flat_defaults/output
readJsonFilesFromFolder /home/gianm/LAGO-data/mediciones/L0/chimbito/output


