#!/usr/bin/env python3

# ─ Copyright Notice ───────────────────────────────────────────────────
#
# Copyright 2000-2025 Hans Deragon - AGPL 3.0 licence.
#
# Hans Deragon (hans@deragon.biz) owns the copyright of this work.  It is
# released under the GNU Affero General Public License which can be found at:
#
#     https://www.gnu.org/licenses/agpl-3.0.en.html
#
# ─────────────────────────────────────────────────── Copyright Notice ─

import os.path
import sys

print( """ 
Avertissement:

  Python timezone est un vrai désastre.  Pour définir un timezone
  en fonction d'un nom, il faut utiliser une librairie nommée
  pytz.  Et ecnore, il est impossible d'obtenir le timezone courant.
  Très complexe.

  Ce script ne marche pas.
  Ce script ne marche pas.
  Ce script ne marche pas.
  Ce script ne marche pas.
""")

# os.path.realpath(os.curdir) # Current directory, canonical form.

scriptPath=os.path.dirname(sys.argv[0])
scriptName=os.path.basename(sys.argv[0])

scriptPathAbs=os.path.realpath(scriptPath)

scriptNameandpathAbs=scriptPathAbs + os.sep + scriptName

try:
  scriptNameBase=scriptName.rsplit('.', 1)[0] # Extension found.
except IndexError:
  scriptNameBase=scriptName # There is no extension.

  scriptPathAbsParent=os.path.dirname(scriptPathAbs)



# PARSING ARGUMENT:0

# ────────────────────────────────────────────────────────────────────────────
#
# See:  http://docs.python.org/2/library/argparse.html

import argparse
parser = argparse.ArgumentParser(description='Compare time between two timezones.')

parser.add_argument('--tz1', dest='tz1', default='',
                    help='Timezone1 (default localtimezone).')
parser.add_argument('--tz2', dest='tz2', default='UTC',
                    help='Timezone1 (default UTC).')
parser.add_argument('--time', dest='time', default=None,
                    help='Time to convert (default is current time).')

args = parser.parse_args()

errors=""

# if args.hardlink == True and args.softlink == True:
#   errors += "\n  --hardlink and --softlink are mutually exclusive.  You must chose one."

if len(errors) > 0:
  print("ERROR:  The following errors were detected:\n" + errors)
  print("\nCommand aborted.")
  sys.exit(1)

print(args)

time = None
if args.time == None:
  time = local_tz.localize(datetime.time())
else:
  

from datetime import datetime
import pytz  # pip install pytz
from pytz import reference
#timezonelist = ['UTC','EDT','EST']
#timezonelist = [tzinfo.tzname(dt), tzinfo.tzname(dt)]

utc=pytz.timezone("UTC")
est=pytz.timezone("EST")
edt=pytz.timezone("EST5EDT")

import tzlocal  # pip install tzlocal
local_tz = tzlocal.get_localzone()

Nomprint(time)

print("UTC:  " + str(time.astimezone(utc)))
print("EST:  " + str(time.astimezone(est)))
print("EDT:  " + str(time.astimezone(edt)))
