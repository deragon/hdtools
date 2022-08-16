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

import os.path
import sys
import logging

from datetime import datetime
import time

import argparse

# os.path.realpath(os.curdir) # Current directory, canonical form.

scriptName=os.path.basename(sys.argv[0])
scriptPath=os.path.dirname(sys.argv[0])

scriptPathAbs=os.path.realpath(scriptPath)
scriptPathAbsParent=os.path.dirname(scriptPathAbs)

scriptNameAndPathAbs=scriptPathAbs + os.sep + scriptName

try:
    scriptNameBase=scriptName.rsplit('.', 1)[0] # Extension found.
except IndexError:
    scriptNameBase=scriptName # There is no extension.

# PARSING ARGUMENTS
# ────────────────────────────────────────────────────────────────────────────
#
# See:  https://docs.python.org/3/library/argparse.html
#
# WARNING:
#
# - and -- options are always optional according to argparse.  If you
# want mandatory arguments, they should not be prefixed with - or --.
#
# http://stackoverflow.com/questions/24180527/argparse-required-arguments-listed-under-optional-arguments


# This piece of code allow the translation of automatic english messages
# generated by argparse into french.
#
# From:  https://stackoverflow.com/questions/22951442/how-to-make-pythons-argparse-generate-non-english-text
# def convertArgparseMessages(s):
#     subDict = \
#     {'positional arguments':'Arguments positionnels',
#     'optional arguments':'Arguments optionnels',
#     'show this help message and exit':'Affiche ce message et quitte'}
#     if s in subDict:
#         s = subDict[s]
#     return s
# import gettext
# gettext.gettext = convertArgparseMessages
# gettext.translation('guess', localedir='locale', languages=['fr']).install()


parser = argparse.ArgumentParser(description="""
\x1B[1;37;42m SAFE \x1B[0m
\x1B[1;30;43m SLIGHT DANGER \x1B[0m
\x1B[1;37;41m DANGER \x1B[0m

\x1B[1;37;42m SAUF \x1B[0m
\x1B[1;30;43m LÉGER DANGER \x1B[0m
\x1B[1;37;41m DANGER \x1B[0m

Read a .ini file and export its full content in variables that Bash can make use of.

For example, run:

    """ + scriptName + """  config.ini --export

""", formatter_class=argparse.RawTextHelpFormatter)

# Positional arguments.
# If <files> is mandatory, use "nargs='+'".  If optional, use "nargs='*'".
parser.add_argument('files', metavar='files', type=str, nargs='+',
                    help='List of files to rename.')

# Mandatory arguments.
# parser.add_argument('-d', '--dst', dest='dst', default='.', required=True,
#                     help='Destination where subdirectories will be created.')

# Optional arguments.
# action="store_true" means is that if the argument is given on the command
# line then a True value should be stored in the parser.
# parser.add_argument('--hardlink', dest='hardlink',
#                     default=False, action="store_true",
#                     help='Create hard links instead of moving files.')
#
# parser.add_argument('-s', '--split', dest='split', default=10, required=False,
#                     help='Number of split to perform.')

# Optional argument with parameter (--user USER).  By putting 'type=str', we
# tell the parser that the argument must take a parameter with it.
# parser.add_argument('-u', '--user', type=str, dest='user',
#                     default=os.environ["USER"], help='Provide user id.')

parser.add_argument('-l', '--log-level', dest='loglevel', default='info',
       choices=['debug', 'info', 'warning', 'error', 'critical'],
       help='Set logs level.  Default is \'info\'.')
#       help='Niveau des logs.  Défaut est \'info\'.')

args = parser.parse_args()

if args.loglevel=="debug":
    level=logging.DEBUG
elif args.loglevel=="warning":
    level=logging.WARNING
elif args.loglevel=="error":
    level=logging.ERROR
elif args.loglevel=="critical":
    level=logging.CRITICAL
else:
    level=logging.INFO

# When setting the log level with logging.basicConfig(), the log level is set
# for ALL Python modules that using the logging facility, not just the code
# found in this script.  This is usually not desired.
#
# It is preferred to use a logger and set the log level only for it, so only
# its logs are showing, not that of other modules (very preferable when the
# log level is set to DEBUG).

# logging.debug("Test of logging %s", "here. :)")
logging.basicConfig(
    format='%(asctime)s - %(levelname)5s - %(funcName)20s(): %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S')

# Creating a logger with the script's name and setting it to a specific log
# level.
logger = logging.getLogger(scriptName)
logger.setLevel(level)
logger.debug("Test of logging %s", "here. :)")


errors=""

# if args.hardlink == True:
#   errors += "\n  --hardlink is required."

if len(errors) > 0:
    print("\x1B[1;37;41mERROR:\x1B[0m  The following errors where detected.\n" + errors + "\n\nCommand aborted.")
    print("\x1B[1;37;41mERREUR:\x1B[0m  Les erreurs suivantes furent détectées.\n" + errors + "\n\nCommande avortée")
    sys.exit(1)

#print(args)

#print("Subdirectories will be created in '" + args.dst + "'.")



# FILE COMMANDS
# ────────────────────────────────────────────────────────────────────────────

import shutil
import pathlib

# rm -rf:  Erase directory, causes no error if not existing.
shutil.rmtree(path, ignore_errors=True, onerror=None)

# mkdir -p:  from Python >= 3.5
pathlib.Path("<directory name/path here>").mkdir(parents=True, exist_ok=True)

shutil.copy2(package, packages_dir) # cp -p (best copy option)
os.chdir("<dir>")  # cd "<dir">

# 'mkdir -p' - OLD CODE (Python 2)?
# import errno
# try:
#   os.makedirs(args.dst + os.sep + str(index) )
# except OSError as oserror:
#   if oserror.errno == errno.EEXIST:
#     pass   # Already exists, we continue.
#
#     import shutil  # Erase directory recursively and recreate it.
#     shutil.rmtree(directory)
#     os.makedirs(directory)
#   else:
#     raise  # Some odd problem, maybe permission problem?  Raising.



# REGULAR EXPRESSION
# ────────────────────────────────────────────────────────────────────────────

import re
pattern = re.compile("<regex>")
matches = pattern.match(line)
if matches != None:
    data=matches.group(1)



# READ AND WRITE TO A FILE
# ────────────────────────────────────────────────────────────────────────────

lines = [ i.strip() for i in open("somefile") ]  # Strips lines

# All in memory
lines = open(file).readlines()  # Lines remain intact.

for line in lines:
    pass

# Not all in memory, one line at a time
lines = open(file)

for line in lines:
    pass

fileOutput = open(filename + ".new" ,'w+')  # '+' means create if does not exists.  'a' is for append.
fileOutput.write(output + "\n")
fileOutput.close()



# JSON
# ────────────────────────────────────────────────────────────────────────────
import json
with open('file.json') as fd:
    json_dict=json.load(fd)

json_dict=json.loads('{ "test": "Hi there." }') # Load json from str.



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


# New: (from:  https://stackoverflow.com/questions/12420779/simplest-way-to-get-the-equivalent-of-find-in-python)

allfiles = [os.path.join(dirpath, filename) for (dirpath, dirs, files) in os.walk('.') for filename in (dirs + files)]


# READ AND WRITE TO A FILES OR STDIN
# ────────────────────────────────────────────────────────────────────────────
if len(args.files) == 0:
    args.files = [ "<stdin>" ]

for file in args.files:

    text=None
    if "<stdin>" in file:
        fd = sys.stdin
        text="".join(fd.readlines())
    else:
        with open(file) as fd:
            # Script files are always small enough to fit into memory.
            # Thus, we load everything since it makes things easier.
            text="".join(fd.readlines())

    # At this point, 'text' contains all the content of the file, each line
    # separated with a newline.  Be aware, too, that a newline can consist of
    # a linefeed (\n), a carriage-return (\r), or a carriage-return+linefeed
    # (\r\n).

    # Searching for lines that match the given regular expression.  WARNING:
    # In multiline mode, ^ matches the position immediately following a
    # newline and $ matches the position immediately preceding a newline, NOT
    # THE NEWLINE ITSELF.
    #
    # See:  https://stackoverflow.com/questions/587345/regular-expression-matching-a-multiline-block-of-text
    pattern = re.compile(r"^\s+Name:\s+(\w+).*$", re.MULTILINE)
    for matches in pattern.finditer(text):
         data=matches.group(1)
         logger.info(">>" + str(data)+ "<<")


# Snippet to print over a line the index we are at.
# import curses
# setupterm()
# index=1000
# print(title, end="")
# indexpos=len(title)+10
# For...
#    print("\r" + curses.tparm(curses.tigetstr("cuf"), indexpos, 0).decode("UTF8") + str(index), end="")



# Old
index=0
for root, dirs, files in os.walk(args.inputdir):
    #print "root="  + str(root)
    #print "dirs="  + str(dirs)
    #print "files=" + str(files)

    numberoffiles = len(files)

    for file in files:
      # basename=os.path.basename(file)

      #from pathlib import Path
      # https://docs.python.org/3/library/pathlib.html
      #basename_without_extension=Path(basename).stem
      #extension=Path(basename).suffix
      #extensions=Path(basename).suffixes  # Return an array, such as PurePosixPath('my/library.tar.gz').suffixes returns ['.tar', '.gz']

      index+=1
      dst_fullpath = args.dst + os.sep + str(index % args.split) + os.sep + file
      src_fullpath = root + os.sep + file

      print("                                                                                \r", end=' ')

      if index%100000 == 0:
        print("Number of entries processed " + str(index)) # + "\n\n"

      if args.hardlink:
        print("Creating hardlink " + src_fullpath + " -> " + dst_fullpath, end=' ')
        os.link(src_fullpath, dst_fullpath)
      elif args.softlink:
        print("Creating softlink " + src_fullpath + " -> " + dst_fullpath, end=' ')
        os.symlink(src_fullpath, dst_fullpath)
      else:
        print("Moving " + src_fullpath + " -> " + dst_fullpath, end=' ')
        os.rename(src_fullpath, dst_fullpath)
      print("\r", end=' ')



def handle_exception(exception):
    logging.error("Exception lancée:  %s", str(exception))

    from configparser import SafeConfigParser
    import traceback
    import socket
    import getpass
    username = getpass.getuser()
    hostname = socket.gethostname()

    config = SafeConfigParser()
    config.read(os.path.join(os.environ["HOME"], "config", "lake.ini"))
    emails = config['Support']['emails'].split(' ')
    env    = config['Environment']['type']

    # Sending an email when an error occured.
    # ────────────────────────────────────────────────────────────────────
    body = "En " + env + """, l'erreur suivante:

  """ + str(exception) + """
  """ + '  '.join(('\n'+traceback.format_exc().lstrip()).splitlines(True)) + """
...c'est produite à l'exécution du script:

  """ + username + "@" + hostname + ":" + scriptNameAndPathAbs

    logging.error("Contenu du courriel d'erreur suit:\n\n%s", body)

    msg = MIMEText(body, 'plain')
    msg['Subject'] = env + " / partition - Erreur sur " + username + "@" + hostname + ":  " + str(exception)
    msg['To'] = ','.join(emails)
    #msg['From']   = sender # some SMTP servers will do this automatically, not all

    conn = SMTP("localhost")
    conn.set_debuglevel(False)
    #conn.login(USERNAME, PASSWORD)
    try:
        conn.sendmail("noreply@videotron.com", emails, msg.as_string())
    finally:
        conn.quit()



def mainwrapper():

    try:

        timeStart = datetime.now()

        main()

        timeEnd = datetime.now()

        timeExecuted=timeEnd-timeStart
        timeExecutedHours, timeExecutedRemainder = divmod(timeExecuted.seconds, 3600)
        timeExecutedMinutes, timeExecutedSeconds = divmod(timeExecutedRemainder, 60)

        timeStartString = timeStart.strftime("%Y-%m-%d %H:%M:%S")
        timeEndString   = timeEnd.strftime("%Y-%m-%d %H:%M:%S")

        print("\nStarted:   " + timeStartString)
        print("Ended:     " + timeEndString)
        print("Executed:  {0:02}:{1:02}:{2:02}".format(\
                timeExecutedHours, timeExecutedMinutes, timeExecutedSeconds))

        print("\nDébuté:    " + timeStartString)
        print("Terminé:   " + timeEndString)
        print("Exécution:  {0:02}:{1:02}:{2:02}".format(\
                timeExecutedHours, timeExecutedMinutes, timeExecutedSeconds))

    except Exception as exception:
        logger.error("Exception:  %s", exception)
        handle_exception(exception)


def main():

    iso8601Human    = time.strftime("%Y-%m-%d %H:%M:%S")
    iso8601Filename = time.strftime("%Y%m%dT%H%M%S")

    # completedProcess = subprocess.run(["ls", "-l", "/dev/null"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)  # Python 3.6 & +
    # print(completedProcess.stdout.decode('utf-8').rstrip())
    # print(completedProcess.stderr.decode('utf-8').rstrip())
    # print(completedProcess.returncode)
    pass # <code here>

if __name__ == "__main__":
    main()
