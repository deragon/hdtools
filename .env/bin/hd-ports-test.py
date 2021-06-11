#!/usr/bin/python

# ─ Copyright Notice ───────────────────────────────────────────────────
#
# Copyright 2000-2021 Hans Deragon - GPL 3.0 licence.
#
# Hans Deragon (hans@deragon.biz) owns the copyright of this work.
#
# It is released under the GPL 3 licence which can be found at:
#
#     https://www.gnu.org/licenses/gpl-3.0.en.html
#
# ─────────────────────────────────────────────────── Copyright Notice ─

import socket
import getopt
import sys

def usage():
  print("""
-f fqdn
""")

timeout = 15.0

try:
  opts, args = getopt.gnu_getopt(sys.argv[1:], \
      "f:t:", \
      ["fqdn:port", "timeout", "help" ])
except getopt.GetoptError:
  # print help information and exit:
  usage()
  sys.exit(255)

fqdnportarray=[]
for option, arg in opts:
  #debug("argv: " + option + arg)
  if option in ("-h", "--help"):
    usage()
    sys.exit(254)
  elif option in ("-f", "--fqdn:port"):
    fqdnportarray.append(arg)
  elif option in ("-t", "--timeout"):
    timeout = float(arg)

exitvalue = 0

for fqdnport in fqdnportarray:
  fqdn, port = fqdnport.split(':')
  fqdn_canonical = socket.getfqdn(fqdn)
  ip = socket.gethostbyname(fqdn_canonical)

  sock = socket.socket()
  socket.setdefaulttimeout(15.0)
  try:
    sock.connect((fqdn, int(port)))
    print("Success", end=' ')
  except socket.error:
    print("Failure", end=' ')
    exitvalue = 1
  print("for " + fqdnport.ljust(30, " ") + \
    "  (" + fqdn_canonical + "/" + ip + ":" + port + ")")

sys.exit(exitvalue)
