



FOLDER_PATH=/home/gianm/ProyectoLago/scripts/blocks

pushd   ../blockchain-verifier


for FILE in "$FOLDER_PATH"/*.block; do


    FILE_NAME=$(basename "$FILE" )
    npx bcverifier -n fabric-block -c $FILE -o results-${FILE_NAME}.json start



done



popd 


