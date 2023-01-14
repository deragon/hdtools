# ─ Copyright Notice ───────────────────────────────────────────────────
#
# Copyright 2000-2023 Hans Deragon - GPL 3.0 licence.
#
# Hans Deragon (hans@deragon.biz) owns the copyright of this work.
#
# It is released under the GPL 3 licence which can be found at:
#
#     https://www.gnu.org/licenses/gpl-3.0.en.html
#
# ─────────────────────────────────────────────────── Copyright Notice ─

from hdlib2 import *


def sha(pwd, charset='utf-8'):
    """ Encode a cleartext password

    Compatible to Apache htpasswd SHA encoding.

    When using different encoding than 'utf-8', the encoding might fail
    and raise UnicodeError.

    @param pwd: the cleartext password, (unicode)
    @param charset: charset used to encode password, used only for
        compatibility with old passwords generated on moin-1.2.
    @rtype: string
    @return: the password in apache htpasswd compatible SHA-encoding,
        or None
    """
    import base64
    import sha

    # Might raise UnicodeError, but we can't do anything about it here,
    # so let the caller handle it.
    pwd = pwd.encode(charset)

    pwd = sha.new(pwd).digest()
    pwd = base64.encodestring(pwd).rstrip()
    return pwd


def crypt(pwd):
    import crypt
    salt = randomString(2, "[a-zA-Z]")
    return crypt.crypt(pwd, salt)

# The md5 python module cannot be used for generating /etc/shadow
# password.  The code is left here in case one day we need it for something
# else
#
# def md5(pwd):
#   import md5
#   md5Object=md5.new()
#   md5Object.update(pwd)
#   return md5Object.hexdigest()


def md5(pwd):
    import crypt
    salt = randomString(2, "[a-zA-Z]")

    # In "man 3 crypt", it is described that prefixing the salt with "$1$"
    # causes crypt to return an MD5-based algorithm.
    #
    # See also:
    #   http://mail.python.org/pipermail/python-list/2000-March/029726.html
    return crypt.crypt(pwd, "$1$" + salt)
