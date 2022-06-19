#!/bin/bash
exists()
{
  command -v "$1" >/dev/null 2>&1
}
if exists curl; then
echo ''
else
  sudo apt update && sudo apt install curl -y < "/dev/null"
fi
bash_profile=$HOME/.bash_profile
if [ -f "$bash_profile" ]; then
    . $HOME/.bash_profile
fi
sleep 1 && curl -s https://raw.githubusercontent.com/berkcaNode/KujiraTr-Script-Kurulum/main/logo.sh 


# set vars
if [ ! $NODENAME ]; then
	read -p "Dugum Isminizi Giriniz: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
echo "export WALLET=wallet" >> $HOME/.bash_profile
echo "export CHAIN_ID=gitopia-janus-testnet" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo 'Dugum Isminiz : ' $NODENAME
echo 'Cuzdan isminiz: ' $WALLET
echo 'Ag ismi       : ' $CHAIN_ID
echo '================================================='
sleep 2

# update
sudo apt update && sudo apt upgrade -y

# packages
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y

# install go
ver="1.17.2"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version

# install gitopia helper
curl https://get.gitopia.com | bash

# download binary
cd $HOME
git clone gitopia://gitopia1dlpc7ps63kj5v0kn5v8eq9sn2n8v8r5z9jmwff/gitopia
cd gitopia
git checkout main
make install

# config
gitopiad config chain-id $CHAIN_ID
gitopiad config keyring-backend file

# init
gitopiad init $NODENAME --chain-id $CHAIN_ID

# addrbook ve genesis yukleniyor
cd $HOME
git clone gitopia://gitopia1dlpc7ps63kj5v0kn5v8eq9sn2n8v8r5z9jmwff/testnets
cp $HOME/testnets/gitopia-janus-testnet/genesis.json $HOME/.gitopia/config/

# set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.001utlore\"/" $HOME/.gitopia/config/app.toml

# set peers and seeds
SEEDS=""
PEERS=""
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.gitopia/config/config.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.gitopia/config/config.toml

# reset
gitopiad unsafe-reset-all

# create service
tee $HOME/gitopiad.service > /dev/null <<EOF
[Unit]
Description=gitopia
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which gitopiad) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

sudo mv $HOME/gitopiad.service /etc/systemd/system/

# start service
sudo systemctl daemon-reload
sudo systemctl enable gitopiad
sudo systemctl restart gitopiad

echo '=============== KURULUM TAMAMLANDI ==================='
echo -e 'Loglarinizi Kontrol Edin: \e[1m\e[32mjournalctl -u gitopiad -f -o cat\e[0m'
echo -e 'Senkronizasyon Durumunu Kontrol Edin: \e[1m\e[32mcurl -s localhost:26657/status | jq .result.sync_info\e[0m'
