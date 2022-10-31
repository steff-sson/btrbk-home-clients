#!/usr/bin/sudo bash
#
# main script caller
read -p "Snapshots und Backups starten? [J]a, [N]ein" -n 1 -r
echo # neue Zeile
if [[ $REPLY =~ ^[Jj]$ ]]
then
  echo "Starte btrbk für Snapshots und Backups!"
  /usr/bin/btrbk -c /etc/btrbk/root.conf run
  /# usr/bin/btrbk -c /etc/btrbk/home.conf run # optional command for further run of configs
  echo "Backups und Snapshots sind fertig."
else
  echo "Breche ab."
fi
