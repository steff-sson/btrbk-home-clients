#!/bin/bash
#
## main script
echo "Snapshots und Backups mit btrbk wird gestartet."
echo "Speichere installierte Pakete nach $HOME/pkglist.txt"
echo "..."
pacman -Q|cut -f 1 -d " " >> $HOME/pkglist.txt
echo "...gespeichert!"
echo "Zum Erstellen von Snapshots und Backups sind root-Rechte erforderlich."
## Ask for sudo priviledges
echo "Du bist als $(whoami) angemeldet."
[ "$UID" -eq 0 ] || exec sudo "$0" "$@"
read -p "Snapshots und Backups starten? [J]a, [N]ein" -n 1 -r
echo # neue Zeile
#
if [[ $REPLY =~ ^[Jj]$ ]]
then    
  echo "Starte btrbk für Snapshots und Backups!"
  /usr/bin/btrbk -c /etc/btrbk/root.conf run
  /usr/bin/btrbk -c /etc/btrbk/home.conf run # optional command for further run of configs
  echo "Backups und Snapshots sind fertig."
  read -p "Drücke eine beliebige Taste zum Beenden." -n 1
else
  echo "Breche ab."
fi