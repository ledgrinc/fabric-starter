#!/usr/bin/env bash
source lib.sh

# When using persistent data volumes, don't recreate the crypto
if [ -d crypto-config/ordererOrganizations -a -z "${FORCE_CLEAN_INSTALL}" ]; then
    echo "Using previously created crypto"
else
    echo $0 "FORCE_CLEAN_INSTALL is set to  ${FORCE_CLEAN_INSTALL}"

    EXECUTE_BY_ORDERER=1 envSubst "templates/cryptogen-orderer-template.yaml" "crypto-config/cryptogen-orderer.yaml"
    EXECUTE_BY_ORDERER=1 runCLI "rm -rf crypto-config/ordererOrganizations && cryptogen generate --config=crypto-config/cryptogen-orderer.yaml && chown $UID -R crypto-config/"

    EXECUTE_BY_ORDERER=1 envSubst "templates/configtx-template.yaml" "crypto-config/configtx.yaml"
    EXECUTE_BY_ORDERER=1 runCLI "mkdir -p crypto-config/configtx && configtxgen -configPath crypto-config/ -outputBlock crypto-config/configtx/genesis.pb -profile OrdererGenesis -channelID orderer-system-channel "
fi
