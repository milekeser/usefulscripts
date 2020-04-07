#!/bin/bash
#
# Install Hyperledger Fabric 2.0.1 on Ubuntu 18.04 Linux.
#
# Check how to use it at:
# https://www.systutorials.com/how-to-install-go-1-13-x-on-ubuntu-18-04/
#
# Authors: Eric Ma (https://www.ericzma.com)
#
# Usage:
#    ./install-hyperledger-fabric-2-ubuntu-18.04.sh
#

set -o errexit
mydir=$(dirname $0)
set -x

echo "Set up Go 1.13.9 ..."
if [[ -e "/usr/local/go-1.13" ]]; then
  echo "Warning: Folder/file /usr/local/go-1.13 exists. It seems you have go 1.13 installed. Skip installation."
else
  $mydir/install-go.sh 1.13.9
fi

bashrcupdated=1
grep 'export GOPATH=$HOME/go' ~/.bashrc && bashrcupdated=0 || bashrcupdated=1

if [[ "$bashrcupdated" == "1" ]]; then
  echo 'export GOPATH=$HOME/go' >> ~/.bashrc
  echo 'export PATH=$GOPATH/bin:$PATH' >> ~/.bashrc
fi

source ~/.bashrc

echo "Installa packages ..."
sudo apt install git curl wget docker docker-compose nodejs npm
sudo npm install npm@5.6.0 -g
sudo usermod -aG docker $USER

echo "Versions of software:"
docker --version
docker-compose --version
npm --version
go version

cd $GOPATH
echo "Install Hyperledger Fabric 2.0.1 binaries and coker images ..."
sg docker -c "curl -sSL https://bit.ly/2ysbOFE | bash -s -- 2.0.1 1.4.6 0.4.18 -s"

echo "Now start test-network ..."
go get -u github.com/hyperledger/fabric-samples || rt=1
cd $GOPATH/src/github.com/hyperledger/fabric-samples
git checkout a026a4ffbfcf69f33a2a25cd71c5a776ca2fdda5
sg docker -c "cd $GOPATH/src/github.com/hyperledger/fabric-samples/test-network && ./network.sh up"
