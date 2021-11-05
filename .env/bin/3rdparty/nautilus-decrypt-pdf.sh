#!/bin/bash

# From:  http://askubuntu.com/questions/231836/how-can-i-batch-decrypt-a-series-of-pdf-files

# AUTHOR:       (c) Glutanimate 2012 (http://askubuntu.com/users/81372/)
# NAME:         PDFdecrypt 0.3
# DESCRIPTION:  A script to batch decrypt PDF files.
# DEPENDENCIES: qpdf zenity libnotify-bin
#               (install via sudo apt-get install qpdf zenity libnotify-bin)
# LICENSE:      GNU GPL v3 (http://www.gnu.org/licenses/gpl.html)
# CHANGELOG:    0.3 - added notifications and basic error checking
#               0.2 - replaced obsolete gdialog with zenity

password=$(zenity --password --title "PDF password required")

RET=$?

if [[ $RET = 0 ]]; then

  while [ $# -gt 0 ]; do
      ENCRYP=$1
      DECRYP=$(echo "$ENCRYP" | sed 's/\.\w*$/_decrypted.pdf/')
      qpdf --password=$password --decrypt "$ENCRYP" "$DECRYP"
      RET=$?
      if [[ $RET != 0 ]]; then
        ERR=1
      fi
      shift
  done

  if [[ $ERR = 1 ]]
    then
        notify-send -i application-pdf "PDFdecrypt" "All documents processed.  There were some errors."
    else
        notify-send -i application-pdf "PDFdecrypt" "All documents decrypted."
  fi

else
  exit
fi
