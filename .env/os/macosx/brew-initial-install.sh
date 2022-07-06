# ─ Copyright Notice ───────────────────────────────────────────────────
#
# Copyright 2000-2022 Hans Deragon - GPL 3.0 licence.
#
# Hans Deragon (hans@deragon.biz) owns the copyright of this work.
#
# It is released under the GPL 3 licence which can be found at:
#
#     https://www.gnu.org/licenses/gpl-3.0.en.html
#
# ─────────────────────────────────────────────────── Copyright Notice ─

#!/bin/bash

# Minimum packages to install

PACKAGES="
      bash
      coreutils
      dirmngr
      findutils
      gawk
      gdbm
      gettext
      gmp
      gnu-getopt
      gnu-indent
      gnu-sed
      gnu-tar
      gnupg
      gnupg2
      gnutls
      gpg-agent
      libassuan
      libgcrypt
      libgpg-error
      libksba
      libtasn1
      libusb
      libusb-compat
      libyaml
      mpfr
      nettle
      openssl
      pcre
      perl
      pinentry
      pstree
      pth
      python
      readline
      ruby
      vim
"

brew install ${PACKAGES}
