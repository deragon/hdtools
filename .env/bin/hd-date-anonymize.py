#!/usr/bin/env python3
# Copyright 2000-2021 Hans Deragon - GPL 3.0 licence.
#
# Hans Deragon (hans@deragon.biz) owns the copyright of this work.
#
# It is released under the GPL 3 licence which can be found at:
#
#     https://www.gnu.org/licenses/gpl-3.0.en.html

print "Code incomplet.  Commande avortée."
sys.exit

import os.path
import sys

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


from datetime import datetime
timeStart = datetime.now()


# PARSING ARGUMENTS
# ────────────────────────────────────────────────────────────────────────────
#
# See:  http://docs.python.org/2/library/argparse.html
#
# WARNING:
#
# - and -- options are always optional according to argparse.  If you
# want mandatory arguments, they should not be prefixed with - or --.
# 
# http://stackoverflow.com/questions/24180527/argparse-required-arguments-listed-under-optional-arguments

import argparse
parser = argparse.ArgumentParser(description='Split folder in multiple folders of equal number of files.')

parser.add_argument('inputdir', metavar='inputdir', type=str,
                   help='Input directory.')
parser.add_argument('--dst', dest='dst', default='.',
                    help='Destination where subdirectories will be created.')
parser.add_argument('--hardlink', dest='hardlink', 
                    default=False, action="store_true",
                    help='Create hard links instead of moving files.')
parser.add_argument('--softlink', dest='softlink',
                    default=False, action="store_true",
                    help='Create soft links instead of moving files.')
parser.add_argument('--split', dest='split', default=10,
                    help='Number of split to perform.')

args = parser.parse_args()

errors=""

if args.hardlink == True and args.softlink == True:
  errors += "\n  --hardlink and --softlink are mutually exclusive.  You must chose one."

if len(errors) > 0:
  print "ERROR:  The following errors were detected:\n" + errors
  print "\nCommand aborted."
  sys.exit(1)



print args

print "Subdirectories will be created in '" + args.dst + "'."

# mkdir -p
# ────────────────────────────────────────────────────────────────────────────

import errno
try:
  os.makedirs(args.dst + os.sep + str(index) )
except OSError as oserror:
  if oserror.errno == errno.EEXIST:
    pass   # Already exists, we continue.
  else:
    raise  # Some odd problem, maybe permission problem?  Raising.


# REGULAR EXPRESSION
# ────────────────────────────────────────────────────────────────────────────

import re
iso8601ReStrYear="((?:19|20)\d\d)"
iso8601ReStrMonth="(0[1-9]|11|12)"
iso8601ReStrDay="(0[1-9]|[1-2]\d|30|31)"
iso8601date = re.compile(iso8601ReStrYear + ".{0,1}" + iso8601ReStrMonth + ".{0,1}" + iso8601ReStrDay)
matches = pattern.match(line)
if matches != None:
  data=matches.group(1)



# READ AND WRITE TO A FILE
# ────────────────────────────────────────────────────────────────────────────

lines = [ i.strip() for i in open("somefile") ]  # Strips lines

# All in memory
lines = open(file).readlines()  # Lines remain intact.

for line in lines:
  <something>

# Not all in memory, one line at a time
lines = open(file)

for line in lines:
  <something>

fileOutput = open(filename + ".new" ,'w')
fileOutput.write(output)
fileOutput.close()



# WALK A DIRECTORY
# ────────────────────────────────────────────────────────────────────────────

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


index=0
for root, dirs, files in os.walk(args.inputdir):
  #print "root="  + str(root)
  #print "dirs="  + str(dirs)
  #print "files=" + str(files)

  numberoffiles = len(files)

  for file in files:
    index+=1
    dst_fullpath = args.dst + os.sep + str(index % args.split) + os.sep + file
    src_fullpath = root + os.sep + file
    
    print "                                                                                \r",

    if index%100000 == 0:
      print "Number of entries processed " + str(index) # + "\n\n"

    if args.hardlink:
      print "Creating hardlink " + src_fullpath + " -> " + dst_fullpath,
      os.link(src_fullpath, dst_fullpath) 
    elif args.softlink:
      print "Creating softlink " + src_fullpath + " -> " + dst_fullpath,
      os.symlink(src_fullpath, dst_fullpath) 
    else:
      print "Moving " + src_fullpath + " -> " + dst_fullpath,
      os.rename(src_fullpath, dst_fullpath) 
    print "\r",


timeEnd = datetime.now()

timeExecuted=timeEnd-timeStart
timeExecutedHours, timeExecutedRemainder = divmod(timeExecuted.seconds, 3600)
timeExecutedMinutes, timeExecutedSeconds = divmod(timeExecutedRemainder, 60)


timeStartString = "{0}-{1:02}-{2:02} {3:02}:{4:02}:{5:02}".format(
                    timeStart.year, \
                    timeStart.month, \
                    timeStart.day, \
                    timeStart.hour, \
                    timeStart.minute, \
                    timeStart.second)

timeEndString =   "{0}-{1:02}-{2:02} {3:02}:{4:02}:{5:02}".format(
                    timeEnd.year, \
                    timeEnd.month, \
                    timeEnd.day, \
                    timeEnd.hour, \
                    timeEnd.minute, \
                    timeEnd.second)

print "\nStarted:   " + timeStartString
print "Ended:     " + timeEndString
print "Executed:  {0:02}:{1:02}:{2:02}".format(\
        timeExecutedHours, timeExecutedMinutes, timeExecutedSeconds)
