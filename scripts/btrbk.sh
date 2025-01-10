#!/bin/bash
#
## main script
echo "Snapshots und Backups mit btrbk wird gestartet."
echo "Speichere installierte Pakete nach $HOME/pkglist.txt"
echo "..."
pacman -Q|cut -f 1 -d " " >> $HOME/pkglist.txt
echo "...gespeichert!"
echo "Zum Erstellen von Snapshots und Backups sind root-Rechte erforderlich."
read -p "Snapshots und Backups starten? [J]a, [N]ein" -n 1 -r
echo # neue Zeile
#
if [[ $REPLY =~ ^[Jj]$ ]]
then 
  exec sudo /usr/bin/btrbk -c /etc/btrbk/root.conf run
  # exec sudo  /usr/bin/btrbk -c /etc/btrbk/home.conf run # optional command for further run of configs
  echo "Backups und Snapshots sind fertig."
  read -p "Drücke eine beliebige Taste zum Beenden."
else
  echo "Breche ab."
fi