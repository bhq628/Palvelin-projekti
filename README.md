# Palvelin-projekti
Projekti, jossa teemme Saltilla palomuurin asennusta idempotenttiseksi.


## Tiivistelmä / projektinkulku

Virtualbox asennus

Vagrant asennus

Salt asennus

Git asennus ja repon kloonaus

Palomuurin konfigurointi

topfile ja lopputestaus

## Uuden virtuaalikoneen luonti vagrantilla

(Miten VirtualBox)
(Miten Vagrant asennettiin?)

Ensin Powershellillä hakemistoon C:\User\vagrantprojeks\ (ei ole oikea polku ehkä)


```
vagrant init debian/bookworm64
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
sudo systemctl restart salt-minion
```

Yhdellä koneessa se jumittui, joten suljettiin ja käynnistettiin salt-minion uudelleen:

```
sudo systemctl stop salt-minion
sudo systemctl start salt-minion
```

Asennetaan git:

```
sudo apt -y install git
```
Otettiin ssh julkinen avain, jotta päästiin git repoon:

```
ssh-keygen
cat .ssh/id_rsa.pub
```

Kopitoitiin julkinen avain gitin SSH avaimiin. Tulostetaan avain kohtaan Settings -> SSH and GPG keys -> New SSH Key.

Kloonataan Github repo koneeseen:

```
git clone git@github.com:bhq628/Palvelin-projekti.git
```

Nyt voidaan asentaa myos palomuurin Salt repolla (suhteellinen polku):

```
sudo salt-call --local --file-root /Palvelin-projekti/srv/salt/ state.apply ufw
```

Asenna palomuuri:

```
sudo apt -y install ufw
```

HUOMIO! ENNEN KUIN ENABLOIT PALOMUURIA, SALLI PORTTI 22 TCP SSH YHTEYTTÄ VARTEN:

```
sudo ufw allow 22/tcp comment 'SSH'
```

Nyt voit enabloida palomuurin:

```
sudo ufw enable
```




Ongelmat:



ongelmia gitin kanssa, tehtyä kansiot gitiin. Collaborator menetti oikeudet luoda kansioita git pullin kautta sudoeditillä muokata tiedostoja, ohitettiin ongelma käyttämällä nano tekstieditoria.

ufw_enablen kanssa tuli virhe. Huomattiin, että oli laitettu enable 2 kertaa.


## Lähteet

Salt asennus https://docs.saltproject.io/salt/install-guide/en/latest/topics/install-by-operating-system/linux-deb.html
Tero Karvisen oppimateriaalit
