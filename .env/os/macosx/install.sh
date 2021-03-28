# Copyright 2000-2021 Hans Deragon - GPL 3.0 licence.
#
# Hans Deragon (hans@deragon.biz) owns the copyright of this code.
#
# It is released under the GPL 3 licence which can be found at:
#
#     https://www.gnu.org/licenses/gpl-3.0.en.html

#!/bin/bash

cat <<EOM
FINDER CONFIGURATION
══════════════════════════════════════════════════════════════════════════════

  Settitng up configuration so that Finder will always show hidden file.

  WARNING:  Finder is also responsible for displaying icons on the desktop.
            Mac OS X stores two hidden files on the Desktop, listed below.
            Thus, once this option is enabled, the files will show up on
            the desktop.

            NEVER DELETE THESE FILES.

            ∙ .localized
            ∙ .DS_Store

EOM

# Make Finder show the hidden (.*) files all the time.
defaults write com.apple.finder AppleShowAllFiles YES


cat <<EOM


KEY MAPPING CONFIGURATION
══════════════════════════════════════════════════════════════════════════════

  Setting up various keyboard configuration to render the Mac more Linux
  and Windows compliant.

EOM

# Keymapping like Windows.
# From:  http://apple.stackexchange.com/questions/16135/remap-home-and-end-to-beginning-and-end-of-line
mkdir -p "${HOME}/Library/KeyBindings"
cat <<EOF >"${HOME}/Library/KeyBindings/DefaultKeyBinding.dict"
{
  "\\UF729"  = moveToBeginningOfParagraph:;                    // Home
  "\\UF72B"  = moveToEndOfParagraph:;                          // End
  "\$\\UF729" = moveToBeginningOfParagraphAndModifySelection:;  // Shift-Home
  "\$\\UF72B" = moveToEndOfParagraphAndModifySelection:;        // Shift-End
}
EOF
