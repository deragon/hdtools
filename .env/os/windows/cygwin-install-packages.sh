#!/bin/bash

# Copyright 2000-2021 Hans Deragon - GPL 3.0 licence.
#
# Hans Deragon (hans@deragon.biz) owns the copyright of this code.
#
# It is released under the GPL 3 licence which can be found at:
#
#     https://www.gnu.org/licenses/gpl-3.0.en.html

# cygutils-extra
#   Provides get 
/setup*.exe \
    --no-admin \
    --quiet-mode \
    -P cygutils-extra \
    -P ImageMagick \
    -P bind \
    -P curl \
    -P bc \
    -P dos2unix \
    -P fdupes \
    -P gettext \
    -P gnupg \
    -P gpg2 \
    -P inettools \
    -P lynx \
    -P mintty \
    -P nc \
    -P ncurses \
    -P openssh \
    -P pcmisc \
    -P perl \
    -P poppler \
    -P procps-ng \
    -P psmisc \
    -P pv \
    -P python \
    -P python27-pip \
    -P python37-pip \
    -P python37-setup \
    -P rsync \
    -P sharutils \
    -P subversion \
    -P tidy \
    -P unzip \
    -P vim \
    -P wget \
    -P zip \
    -P make \


# gettext provides:  envsubst

# poppler provides:  pdftotext

#  Concernant Git, il vaut mieux utiliser le 'Git for Windows' sous Cygwin.
#  Voir: https://git-scm.com/download/win

  # -p git \

python3 -m pip install chardet
