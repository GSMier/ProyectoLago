CHANNEL_NAME="lagochannel"
 

 echo $CHANNEL_NAME

 configtxgen -profile LAGOChannel -configPath . -channelID $CHANNEL_NAME -outputBlock ../artifacts/$CHANNEL_NAME.block