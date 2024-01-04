MANIPULATIONS DE TEXTE
============================================================================

  - <CTRL-K> <digraph sequence>  - :help dig

      Bullets:  ∙ Sb   ▪ sB
      Arrows:   → ->    ← <-    ↓ -v    ↑ -!
      Math:     ≈ 2?
      Misc:     ¢ c|   ℃  oC
      Bullets:  ⚫ ??   ○ 0m   ● 0M

  - Fix indentation:  gg=G
      Voir:  https://vim.fandom.com/wiki/Fix_indentation


  - Search and replace in visual selection / block:
      From:  https://vim.fandom.com/wiki/Search_and_replace_in_a_visual_selection

      The substitute command (:s) applies to whole lines, however the \%V atom
      will restrict a pattern so that it matches only inside the visual
      selection. This works with characterwise and blockwise selection (and is
      not needed with linewise selection).

      :s/\%Vus/az/g


  CAMELCASE
  ‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑
    ,c  Converti _ → CamelCase
    ,u  Converti CamelCase → _



  RETRAIT DES ACCENTS (DIACRITICS)
  ‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑

    - Sélectionner le texte dont il faut retirer les accents.
    - Appeler la fonction 'RemoveDiacritics'



ALIGNEMENT
======================================================================

  Align columns: :'<,'>Tabularize / /

  Align on ':'    → <Leader>ac  ([A]lign by [C]olon)
  Align on '='    → <Leader>ae  ([A]lign by [E]qual)
  Align on <tab>  → <Leader>at  ([A]lign by [T]ab)

  Align on ',' (comma) without adding spaces:  →  '<,'>Tab /,\zs/

  LotBloc - startTimeStamp & endTimeStamp maintenant forcé au format ISO-8601 ('YYYY-MM-DD HH24:MI:SS').



ENCODE/DECODE HTML
============================================================================

    Set visual mode sur le texte, puis [u (encode) ou ]u (decode)
    Doc sur: vim-unimpaired/README.markdown



FIND RANGE OF CHARACTER
============================================================================

  /[\u007F-\uFFFF]

    Recherche de caractères autres que ANSI 7 bits.

  /[\x00-\x1F]

    Cela ne marche que pour les caractères ASCII.  Impossible d'utiliser
    cette syntaxe pour du Unicode ( [\xFFFF] est traduit par [\xFF]FF, donc
    match le caractère 'F' aussi).  Il faut utiliser [\u0000] pour du
    Unicode.



VISUAL COLUMN MODE *visual mode* (CTRL-V) TRICKS
======================================================================

  Selecting lines with different lengths in visual block mode
  ────────────────────────────────────────────────────────────────────────────
    From:  http://stackoverflow.com/questions/20729712/selecting-lines-with-different-lengths-in-visual-block-mode

    Use $

    To select all the following text in a visual column mode, use $ to tell
    the visual block to select until the end of the line.

      Length long, very long
      Length long, very, very long
      Lenght short
      Shortest



FOLDING *hdfolding*
======================================================================

  zR Open  all folds
  zM Close all folds

  https://www.linux.com/learn/vim-tips-folding-fun

  zf#j creates a fold from the cursor down # lines.
  zf/string creates a fold from the cursor to string.
  zj moves the cursor to the next fold.
  zk moves the cursor to the previous fold.
  zo opens a fold at the cursor.
  zO opens all folds at the cursor.
  zm increases the foldlevel by one.
  zM closes all open folds.
  zr decreases the foldlevel by one.
  zR decreases the foldlevel to zero -- all folds will be open.
  zd deletes the fold at the cursor.
  zE deletes all folds.
  [z move to start of open fold.
  ]z move to end of open fold.



SQL FORMATTER
======================================================================

  https://github.com/vim-scripts/SQLUtilities

  Call function 'SQLFormatter'



Editing this file *hdediting*
======================================================================

  To regenerate the help tags after changing this help file, run:

    :helpt $HDVIM/doc



CSV
======================================================================

  - Set delimiter:  :CSVNewDelimiter \^



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
