# GitopiaTR-script-kurulum


### explorer
https://explorer.gitopia.com/

### Orijinal reher
https://docs.gitopia.com/validator-setup/index.html

### Script ile hizli kurulum
```
wget https://raw.githubusercontent.com/berkcaNode/GitopiaTR-script-kurulum/main/gitopiaberk.sh && bash gitopiaberk.sh
```

### Degiskenleri yukle
```
source $HOME/.bash_profile
```

### cuzdan olusturun (hatırlatıcı kelimeleri kaydetmeyi unutmayin)
```
gitopiad keys add $WALLET
```
or
### Eski cuzdanınızı kurtarabilirsiniz. (yeni kurulum yapanlar bu adımı atlayabilir)
```
gitopiad keys add $WALLET --recover
```

### Dogrulayıcı olustur
```
gitopiad tx staking create-validator \
  --amount 1000000utlore \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.1" \
  --min-self-delegation "1" \
  --pubkey  $(gitopiad tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id $CHAIN_ID
```

### cuzdan bilgilerini kaydet (İSTEĞE BAĞLI)
```
WALLET_ADDRESS=$(gitopiad keys show $WALLET -a)
VALOPER_ADDRESS=$(gitopiad keys show $WALLET --bech val -a)
echo 'export WALLET_ADDRESS='${WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export VALOPER_ADDRESS='${VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

## Faydalı komutlar
Senkronizasyon durumunu kontrol etmek için
```
curl -s localhost:26657/status | jq .result.sync_info
```

### Servis komutları

Gunlukleri goruntulemek icin

```
journalctl -fu gitopiad -o cat
```

Durdurmak icin
```
systemctl stop gitopiad
```

Baslatmak icin
```
systemctl start gitopiad
```

Yeniden baslatmak
```
systemctl restart gitopiad
```

### Genel cosmos komutları
Daha fazla jeton yatırın (eğer doğrulayıcı hissenizi artırmak istiyorsanız, valoper adresinize daha fazla jeton yatırmalısınız):
```
gitopiad tx staking delegate $VALOPER_ADDRESS 10000000utlore --from $WALLET --chain-id $CHAIN_ID --fees 5000utlore
```

Yeniden delege etme
```
gaiad tx staking redelegate $VALOPER_ADDRESS <dst-validator-operator-addr> 100000000utlore --from=$WALLET --chain-id=$CHAIN_ID
```

Odulleri cekme
```
gitopiad tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$CHAIN_ID
```

Cuzdan adresini gorme
```
gitopiad keys show $WALLET --bech val -a
```

Cuzdan bakiyesini gorme
```
gitopiad query bank balances $WALLET_ADDRESS
```

Validatorunuzun komisyon oranını degistirin
```
gitopiad tx staking edit-validator --commission-rate "0.02" --moniker=$NODENAME --chain-id=$CHAIN_ID --from=$WALLET
```

Dogrulayıcınızı duzenleyin
```
gitopiad tx staking edit-validator \
--moniker=$NODENAME \
--identity=1C5ACD2EEF363C3A \
--website="http://kjnodes.com" \
--details="Providing professional staking services with high performance and availability. Find me at Discord: kjnodes#8455 and Telegram: @kjnodes" \
--chain-id=$CHAIN_ID \
--from=$WALLET
```

Unjail validator (hapisten cıkma)
```
gitopiad tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$CHAIN_ID \
  --gas=auto \
  --gas-adjustment=1.4
```

### Dugumu silme
Bu komutlar düğümü sunucudan tamamen kaldıracaktır. Kendi sorumluluğunuzda kullanın!
```
systemctl stop gitopiad
systemctl disable gitopiad
rm /etc/systemd/system/gitopia* -rf
rm $(which gitopiad) -rf
rm $HOME/.gitopia* -rf
rm $HOME/gitopia -rf
```
