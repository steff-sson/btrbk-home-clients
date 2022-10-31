# btrbk-home-clients

Meine persönliche Backupstrategie auf Basis es wundervollen Werkzeugs [Btrbk](https://github.com/digint/btrbk).

## Paketinhalte
* In `services` findest du die Systemd-Service- und -Timer Dateien nach Gerät sortiert.
* In `btrbk`findest du die Konfigurtionsdateien für btrbk nach Geräten sortiert.
* `services/pkglist.service` wird von jedem Gerät beim Start ausgeführt. Der Service schreibt mit [pacman](https://wiki.archlinux.org/title/pacman) eine aktuelle Liste installierter Pakte.

## Installation mit Systemd-Services (Autostart)
**Hinweis: btrbk muss installiert sein!**

Klone das  repository
```
git clone https://github.com/steff-sson/btrbk-home-clients.git && cd btrbk-home-clients
```
Mache notwendige Änderungen an den Konfigurationsdateien und kopiere sie anschließend nach /etc/btrbk
```
nano btrbk/client/root.conf
```
```
nano btrbk/client/root.conf
```
```
sudo cp btrbk/client/* /etc/btrbk/
```
Mache notwendige Änderungen an den Systemd-Servicefiles und kopiere sie anschließend nach /etc/systemd/system
```
nano services/client/btrbk-root.service
```
```
nano services/client/btrbk-home.service
```
```
sudo cp services/client/* /etc/systemd/system/
```

Aktiviere die Systemd-Services
```
sudo systemctl enable btrbk-root.service && sudo systemctl enable btrbk-home.service
```


## Installation mit desktop-Datei für manuellen Start (ohne Services!)
**Hinweis: btrbk muss installiert sein!**

Klone das  repository
```
git clone https://github.com/steff-sson/btrbk-home-clients.git && cd btrbk-home-clients
```
Mache notwendige Änderungen an den Konfigurationsdateien und kopiere sie anschließend nach /etc/btrbk
```
nano btrbk/client/root.conf
```
```
nano btrbk/client/root.conf
```
```
sudo cp btrbk/client/* /etc/btrbk/
```
Wenn du mehr als eine Konfigurationsdatei hast, editiere das Shell-Script, indem die eine weitere Zeile für den btrbk-Befehl auskommentierst und durch deine weitere Konfigurationsdatei ergänzt
```
nano scripts/btrbk.sh

# /usr/bin/btrbk -c /etc/btrbk/home.conf run # optional command for further run of configs
```
Installiere das Shell-Script
```
sudo cp scripts/btrbk.sh /usr/local/bin/ && sudo chmod +x /usr/local/bin/btrbk.sh
```
Installiere die Desktop-Datei
```
desktop-file-install --dir=$HOME/.local/share/applications scripts/btrbk.desktop && update-desktop-database ~/.local/share/applications
```

## Architektur
* Es gibt **einen zentralen** Backup-Server, der Backups empfängt.
* **Backup-Clients** können der Backup-Server selbst sein (z.B. Subvolumes innerhalb des Servers), aber auch Subvolumes anderer Geräte innerhalb des Netzwerkes.
* Backup-Cliets rufen **btrbk** täglich mittels eigens erstellter Systemd-Services auf.
* Btrbk erstellt je ein **Snapshot** und ein **Backup** (in Btrfs-Terminologie `btrfs send|receive`) – beides sind BTRFS-Snapshots von Subvolumes.
* Dazu müssen die dafür erforderlichen Suubvolumes vorhanden sein.
* Für Snapshots und Backups können unterschiedliche Aufbewahrungszeiten (**snapshot_preserve** und **target_preserve**) eingestellt werden.
* Für jeden Service existiert eine eigene *.conf Datei für btrbk, damit jeder Service btrbk mit `-c`die jeweilige Konfiguratonsdatei öffnen kann.

## Erklärung
### Backup-Server (friedl)
* **/@snapshots** - für eigene snapshots des Root-Dateisystems
* **/volume1/@snapshots** für Backups der Clients und Snapshots der Daten
* **/volumeUSB/@snapshots** für zusätzliche Backups der Clients
* BTRBK wird mit drei Services aufgerufen, die jeweils mit einem Timer zeitgesteuert werden:
  * **btrbk-root.service** schreibt um 03:00 Uhr Snapshots von **/@** und **/@home** sowie darauf aufbauend Backups nach **/volume1/@snapshots/friedl** und **/volumeUSB/@snapshots/friedl**
  * **btrbk-daten.service** schreibt um 03:30 Uhr Snapshots von **/volume1/@daten** sowie darauf aufbauend Backups nach **/volumeUSB/@snapshots/friedl**
  * **btrbk-video.service** schreibt um 05:10 Uhr Snapshots von **/volume1/@video** nach **/volume1/@snapshots/friedl** sowie darauf aufbauend Backups nach **/volumeUSB/@snapshots/friedl**.

### stef-notebook
* **/@snapshots** - für eigene snapshots des Root-Dateisystems
* **/@backups** - für lokale Backups
* BTRBK wird mit zwei Services aufgerufen:
  * **btrbk-root.service** schreibt Snapshots von **/@** sowie darauf aufbauend Backups nach **/@backups** (lokale Backups)
  * **btrbk-home.service** schreibt Snapshots von **/@home** sowie darauf aufbauend Backups nach **[IP-Backup-Server]/volume1/snapshots/stef-notebook** und **ssh://[IP-Backup-Server]/volumeUSB/snapshots/stef-notebook** (remote Backups)

### Johanna-Laptop
* folgt dem selben muster wie "stef-notebook"

### Hinweis zu Remote Backups
* Damit btrbk auf entfertne Server per SSH zugreifen kann, muss ein SSH-Kepair angelegt und auf der öffentliche Schlüssel (publickey) auf den Server kopiert werden.
* ACHTUNG: Dazu muss der Server den root-Zugriff temporär ermöglichen! (siehe [Arch-Wiki](https://wiki.archlinux.org/title/OpenSSH#Limit_root_login))
* Führe folgende Schritte aus, um ein Schlüsselpaar zu erstellen und zu kopieren:
```
ssh-keygen -t ed25519 -f /etc/btrbk/id_btrbk
ssh-copy-id -i /etc/btrbk/id_btrbk.pub root@[IP-Backup-Server]
```
* Im Anschluss kann der root-Zugriff wieder beschränkt werden. (siehe [Arch-Wiki](https://wiki.archlinux.org/title/OpenSSH#Limit_root_login))
