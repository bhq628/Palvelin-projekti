# Palvelin-projekti


## Vaatimukset ja asennusohjeet

Virtualbox https://www.virtualbox.org/manual/topics/installation.html

Salt https://docs.saltproject.io/salt/install-guide/en/latest/topics/install-by-operating-system/index.html

Git https://git-scm.com/install/windows

Vagrant https://developer.hashicorp.com/vagrant/docs/installation

## Tiivistelmä / projektinkulku

Virtualbox asennus

Vagrant asennus

Salt asennus

Git asennus ja repon kloonaus

Palomuurin konfigurointi

topfile ja lopputestaus


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
sudo salt-call --local --file-root /Palvelin-projekti/srv/salt/ state.apply
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




## Helppo ja nopeampi tapa

Vagrant skriptillä voidaan kätevästi luoda master minion arkkitehtuuri.

Skriptiin on luotu valmiit asetukset ja hyvän alun tähän projektiin.

Tämä voidaan lisätä Vagrantfile tiedostoon:

```
# -*- mode: ruby -*-
# vi: set ft=ruby :

$master_script = <<MASTERSCRIPT
set -o verbose
sudo apt update
sudo mkdir -p /etc/apt/keyrings/
sudo apt -y install curl
curl -fsSL https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public \ | sudo tee /etc/apt/keyrings/salt-archive-keyring.pgp
curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources \ | sudo tee /etc/apt/sources.list.d/salt.sources
sudo apt update
sudo apt -y install salt-master salt-common
sudo systemctl enable salt-master
sudo systemctl restart salt-master
sudo apt -y install git
sudo apt -y install ufw
sudo ufw allow 22/tcp
sudo ufw allow 4505/tcp
sudo ufw allow 4506/tcp
MASTERSCRIPT

$minion_script = <<MINIONSCRIPT
set -o verbose
sudo apt update
sudo mkdir -p /etc/apt/keyrings/
sudo apt -y install curl
curl -fsSL https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public \ | sudo tee /etc/apt/keyrings/salt-archive-keyring.pgp
curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources \ | sudo tee /etc/apt/sources.list.d/salt.sources
sudo apt update
sudo apt -y install salt-minion salt-common
echo "master: 192.168.88.10" | sudo tee /etc/salt/minion
sudo systemctl enable salt-minion
sudo systemctl restart salt-minion
MINIONSCRIPT

Vagrant.configure("2") do |config|
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.synced_folder "shared/", "/home/vagrant/shared", create: true
  config.vm.box = "debian/bookworm64"
    
  # Salt Master machine
  config.vm.define "master" do |master|
    master.vm.hostname = "salt-master"
    master.vm.network "private_network", ip: "192.168.88.10"
    master.vm.provision "shell", inline: $master_script

    master.vm.provider "virtualbox" do |vb|
      vb.memory = 2048 
      vb.cpus = 2  
    end
  end

  # Salt Minion machine
  config.vm.define "minion" do |minion|
    minion.vm.hostname = "salt-minion"
    minion.vm.network "private_network", ip: "192.168.88.11"
    minion.vm.provision "shell", inline: $minion_script

    minion.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus = 2
    end
  end
end
```

Lisättyä skriptin Vagrantfile tiedostoon, ajetaan se 

`vagrant up`

Nyt on master ja minion kone luotu. 

Siihen pystyy myös luoda lisää hallitettavia koneita lisäämällä skriptiin lisää minion koneita. Koneet kommunikoivat toistensa kanssa, minion kone saa yhteyden master koneelle. Vaaditaan minion avaimen hyväksymisen master koneella.

Kirjaudutaan minion koneelle: 

`vagrant ssh minion`

Käynnistetään salt-minion.service:

`sudo systemctl restart salt-minion.service`

Nyt master koneella voidaan hyväksyä minion avain.

Kirjaudutaan masterille ja hyväksytään minion avain:

```
exit
vagrant ssh master
sudo salt-key -A
```

Git on jo valmiina asennettu skriptin kautta. Git repon kloonaamista varten tarvitaan ssh julkinen avain: 

`ssh-keygen`

Kopioidaan julkinen avain:

`cat .ssh/id_rsa.pub`

Hyväksytään avain GitHubissa Settings -> SSH and GPG Keys -> New SSH Key.

Nyt voidaan kloonata tämä repo klikkaamalla vihreetä painiketta Code -> SSH ja kopioidaan linkki:

<img width="572" height="498" alt="Näyttökuva (77)" src="https://github.com/user-attachments/assets/39e31e0d-3f13-4221-9c45-ca377b9b1aaa" />


Kloonataan git repo master koneelle 

`git clone git@github.com:bhq628/Palvelin-projekti.git` 

Kopioidaan sieltä Salt repo 

`sudo cp -r Palvelin-projekti/srv/salt/ /srv/salt/`

Nyt voidaan ajata moduuli minionille 

`sudo salt '*' state.apply`

## Keskitetty hallitus tiivistelmä:

```
vagrant up
vagrant ssh minion
sudo systemctl restart salt-minion.service
exit
vagrant ssh master
sudo salt-key -A
ssh-keygen
cat .ssh/id_rsa.pub          #kopioi tulostettu avain GitHubiin
git clone git@github.com:bhq628/Palvelin-projekti.git
sudo cp -r Palvelin-projekti/srv/salt/ /srv/salt/
sudo salt '*' state.apply    #moduulin ajo minioniin
```


Kehitettävää:

GitFS toiminto, niin voi ajata moduulin suoraan git reposta minioniin


## Ongelmat:



ongelmia gitin kanssa, tehtyä kansiot gitiin. Collaborator menetti oikeudet luoda kansioita git pullin kautta sudoeditillä muokata tiedostoja. Yritettiin korjata ongelma muokkaamalla kansioiden oikeuksia, mutta se ei korjanut ongelmia ja jopa esti pääsyn salt hakemistolle. Poistettiin repo koneesta ja kloonattiin uudelleen. Sudoeditin ongelma ohitettiin käyttämällä nano tekstieditoria.

ufw_enablen kanssa tuli virhe. Huomattiin, että oli laitettu enable 2 kertaa.


Jatkettiin tekemään template master ja minion koneelle:

Asentaa Dedbianin ja niihin Saltin että gitin.

Ne kommunikoivat toisten kanssa, pitää lähettää minionin avain masterille `sudo systemctlr restart minion.service` minion koneella ja hyväksyä masterilla `sudo salt-key -A`.

## Lähteet

Git asennusohje https://git-scm.com/install/windows

Salt asennusohje https://docs.saltproject.io/salt/install-guide/en/latest/topics/install-by-operating-system/index.html

Tero Karvisen oppimateriaalit

Vagrant asennusohje https://developer.hashicorp.com/vagrant/docs/installation

Virtualbox https://www.virtualbox.org/manual/topics/installation.html



