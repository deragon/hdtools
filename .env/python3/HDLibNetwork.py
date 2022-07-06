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

# IP address manipulation functions, dressed up a bit

import socket
import struct

# From http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/66517


def dottedQuadToNum(ip):
    "convert decimal dotted quad string to long integer"
    # Comment by Hans Deragon, 2007/04/27, 20:26 EDT
    # Fixed the original function according to comment.  Using '!L'
    # as argument to get a big endian result.
    return struct.unpack('!L', socket.inet_aton(ip))[0]

# From http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/66517


def numToDottedQuad(n):
    "convert long int to dotted quad string"
    return socket.inet_ntoa(struct.pack('L', n))

# From http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/66517


def makeMask(n):
    "return a mask of n bits as a long integer"
    return (2 << n-1)-1

# From http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/66517


def ipToNetAndHost(ip, maskbits):
    "returns tuple (network, host) dotted-quad addresses given IP and mask size"
    # (by Greg Jorgensen)

    n = dottedQuadToNum(ip)
    m = makeMask(maskbits)

    host = n & m
    net = n - host

    return numToDottedQuad(net), numToDottedQuad(host)
