#!/usr/bin/env python3

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

# WARNING:
#
# This script is far from perfect.  It makes use of os.walk that reads
# in memory all the files.  Thus if you have say 30E06 files, this script
# will consume Gib of memories.
#
# Python is missing a feature which would allow to scan a directory
# without loading all of its content in memory.
#
# This issue is:  http://bugs.python.org/issue11406

import os.path
import sys
import argparse
from datetime import datetime

# os.path.realpath(os.curdir) # Current directory, canonical form.

script_path=os.path.dirname(sys.argv[0])
script_name=os.path.basename(sys.argv[0])

script_path_abs=os.path.realpath(script_path)

script_nameandpath_abs=script_path_abs + os.sep + script_name

try:
  script_name_base=script_name.rsplit('.', 1)[0] # Extension found.
except IndexError:
  script_name_base=script_name # There is no extension.

script_path_abs_parent=os.path.dirname(script_path_abs)




parser = argparse.ArgumentParser(description='Replace "pattern" with content of
the corresponding environment variable.')

parser.add_argument('--pattern', dest='pattern', 
                    default=False, action="store_true",
                    help='Pattern')

args = parser.parse_args()

errors=""

if args.pattern == True and args.softlink == True:
  errors += "\n  --hardlink and --softlink are mutually exclusive.  You must chose one."

if len(errors) > 0:
  print "ERROR:  The following errors were detected:\n" + errors
  print "\nCommand aborted."
  sys.exit(1)

pattern.


print args
#if args.dst == None:
#  print "No destination directory provided.  Default to '.'"
#  dstDir='.'
#else:
#  dstDir=args.dst

#hardlink=args.hardlink
#  print "No destination directory provided.  Default to '.'"
#  dstDir='.'
#else:
#  dstDir=args.dst



