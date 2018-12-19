#!/usr/bin/env bash
source lib.sh
usageMsg="$0 channelName "
exampleMsg="$0 common "

IFS=
channelName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}

if [ -z "$LOCAL_DEVMODE" ]; then
    export TLS_SUFFIX="--tls --cafile /etc/hyperledger/crypto/orderer/tls/ca.crt"
else
    export TLS_SUFFIX=""
fi

echo "Create channel $ORG $channelName"
downloadMSP
runCLI "mkdir -p crypto-config/configtx"
envSubst "templates/configtx-template.yaml" "crypto-config/configtx.yaml"
runCLI "configtxgen -configPath crypto-config/ -outputCreateChannelTx crypto-config/configtx/channel_$channelName.tx -profile CHANNEL -channelID $channelName \
    && peer channel create -o orderer.$DOMAIN:7050 -c $channelName -f crypto-config/configtx/channel_$channelName.tx $TLS_SUFFIX"
#updateChannelModificationPolicy $channelName
updateAnchorPeers "$channelName"
