# Palvelin-projekti
Projekti, jossa teemme Saltilla palomuurin asennusta idempotenttiseksi.


## Uuden virtuaalikoneen luonti vagrantilla

(Miten VirtualBox)
(Miten Vagrant asennettiin?)

Ensin Powershellillä hakemistoon C:\User\vagrantprojeks\ (ei ole oikea polku ehkä)


```
init vagrant debian/bookworm64
vagrant up
vagrant ssh
```

```
sudo apt update
sudo apt -y upgrade
```

Varmistettiin, että mkdir -p /etc/apt/keyrings kansio oli olemassa.

```
sudo apt -y install curl

curl -fsSL https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public | sudo tee /etc/apt/keyrings/salt-archive-keyring.pgp

curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources | sudo tee /etc/apt/sources.list.d/salt.sources

sudo apt update
sudo apt install salt-common
sudo apt install salt-minion

sudo systemctl enable salt-minion

sudo systemctl status salt-minion.service
```
