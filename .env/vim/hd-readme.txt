WINDOWS
======================================================================

  GVIM
  --------------------------------------------------------------------

  1.  Dans le fichier C:\programs\Vim7.2\Vim\_vimrc, s'assurer que les
      première lignes débutent avec ce qui suit:

      " Added by Hans Deragon
      source C:\cygwin\home\hderagon\.hans.deragon\.env\vim\.vimrc

      set nocompatible
      "source $VIMRUNTIME/vimrc_example.vim
      "source $VIMRUNTIME/mswin.vim
      behave mswin

  2.  Il faut configurer la variables d'environnement $HDVIM avec la valeur du
      répertoire vim (C:\cygwin\home\hderagon\.hans.deragon\.env\vim) au
      niveau de Windows.

      Paneau de configuration / Système / Paramètres système avancés /
      Variables d'environnements




WINDOWS GVIM AND DEAD KEYS
======================================================================

  Apparemment, corriger sous 7.4.413.

  https://code.google.com/p/vim/issues/detail?id=250&sort=-id
  http://stackoverflow.com/questions/3937237/gvim-us-international-not-combining-dead-keys-with-space



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
