Pour exécuter les fichiers *.reg, il suffit d'ouvrir 'regedit.exe' et choisir
'File/import...', puis sélectionner le fichier '*.reg' ciblé.

Généralement, les droits admins sont requis.


  caps_lock_to_control-noadminrights-nemarchepas.reg
  ────────────────────────────────────────────────────────────────────────────

    Ai trouvé sur le web.  Devrait marcher sans avoir besoin de droits
    administrateur, mais n'a pas marché sur le Windows 10 de Desjardins.


  caps_lock_to_control.reg
  ────────────────────────────────────────────────────────────────────────────

    Droit administrateurs requis.  Reboot absolument nécessaire après.

    Vidétron 2020:

      Confirmé, ça marche.  Reboot nécessaire.

    Desjardins:

      Ce fichier a marché sur Windows 10 chez Desjardins.
      TI l'a installé car il faut les droits administratif que mon
      usager N1 n'avait pas; je ne pouvais pas l'exécuter.



OLD DOC, NOT VERY USEFUL WINDOWS 7 - CAPS DEVIENT CTRL
══════════════════════════════════════════════════════════════════════════════

  - Start the Windows Registry Editor. If you have Windows XP or an earlier
    version of Windows, click on "Start," click "Run," then enter "regedit" and
    click "OK." If you have Windows Vista, click the "Start" button and enter
    "regedit" in the search box. Click on the "regedit" link that appears on the
    menu.

  - Go to the "HKEY_CURRENT_USER\Keyboard Layout" folder to remap the "Caps
    lock" key just for the user account you are using. Go to the
    "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layout" folder
    to remap the key for all users on the computer. You must have administrator
    privileges to make the changes for all users.

  - Click on "edit," New" then "Binary Value." A new key will appear in the
    folder. Name the key "Scancode Map" without the quotation marks.

  - Double-click on the "Scancode Map" key. A box labeled "Edit Binary Value"
    will pop up.

  - Type "00 00 00 00 00 00 00 00 02 00 00 00 1D 00 3A 00 00 00 00 00" without
    the quotation marks. Do not type the spaces -- they will appear
    automatically after every two characters. Click "OK" once the correct
    numbers have been entered.

  - Close the Registry Editor and reboot your computer to implement to new key
    mapping.



█ ─ Copyright Notice ───────────────────────────────────────────────────
█
█ Copyright 2000-2024 Hans Deragon - AGPL 3.0 licence.
█
█ Hans Deragon (hans@deragon.biz) owns the copyright of this work.  It is
█ released under the GNU Affero General public Picense which can be found at:
█
█     https://www.gnu.org/licenses/agpl-3.0.en.html
█
█ ─────────────────────────────────────────────────── Copyright Notice ─
