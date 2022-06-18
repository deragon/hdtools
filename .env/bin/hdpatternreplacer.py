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

# This program can be imported as a module so that any of its function
# can be used within another python program.

import os
import sys
import re

scriptName=os.path.basename(sys.argv[0])

# Cannot use 'import argparse' to parse args because at the moment of writting
# of this script, it ran on 'CentOS release 6.3 (Final)' which comes with
# python 2.6 that does not include the module.
#
# We use getopt since it is available and should be in future version
# of Python.  One might replace the code below with 'argparse' if needed.
import getopt

patternRe = re.compile("\[\[.*?\]\]", re.DOTALL)
notFoundString = " : not found"
inPlace = False
outputFilename = None
quiet=False



# ────────────────────────────────────────────────────────────────────────────
def usage():
  print(scriptName + """ --inplace | --output <file> <file-template.1> ...

Replace patterns [[<variable name>]] with content of ${variable name} from
the environment.
""")



# ────────────────────────────────────────────────────────────────────────────
def trace(string):
  # Printing only if not sending output to stdout
  if not quiet and outputFilename != "--":
    print(scriptName + ":  " + string)



# ────────────────────────────────────────────────────────────────────────────
def parseArgs(args):
  global inPlace
  global outputFilename
  try:
    opts, inputFilenames = \
        getopt.getopt(args, "ioh", ["in-place", "output=", "help"])
  except getopt.GetoptError as err:
    # Print help information and exit.
    # Will print something like "option -a not recognized"
    print("Error:  " + str(err)) 
    usage()
    sys.exit(3)

  for o, a in opts:
    if o == "-v":
      verbose = True
    elif o in ("-i", "--in-place"):
      inPlace=True
    elif o in ("-o", "--output"):
      outputFilename = a
    elif o in ("-h", "--help"):
      usage()
      sys.exit(1)
    else:
      print("Syntax error.\n")
      usage()
      sys.exit(2)

  if not inPlace and outputFilename is None:
    print("ERROR:  You need to specify --in-place or provide an output file with --output.")
    sys.exit(10)

  # Replacements values are read from the OS environment variables.  This could
  # later be replaced easily by something else.  Just ensure that 'replacements'
  # is a list.
  replacements=os.environ
  return inputFilenames, outputFilename, replacements



# ────────────────────────────────────────────────────────────────────────────
def processFile(inputFilename, outputFilename, replacements):
  trace("Processing '" + inputFilename + "'.")

  file=open(inputFilename, 'r')
  contentOrg = file.read()
  file.close()
  contentNew = processContent(contentOrg, replacements)

  if contentNew == None:
    # If contentNew == None, it means that the content has not changed.
    if inPlace:
      # Content has not changed and we are asked to change the existing
      # file.  We do no touch the existing file, so we do nothing.
      return
    else:
      # We still want to output the original content, unchanged.
      contentNew = contentOrg

  if inPlace:
    outputFilename = inputFilename

  if outputFilename == "--":
    sys.stdout.write(contentNew)
  else:
    file=open(outputFilename, 'w')
    file.write(contentNew)
    file.close()

  #trace("New content:\n" + str(contentNew))

# ────────────────────────────────────────────────────────────────────────────
# 'contentOrg'   is a string.
# 'replacements' is a list.
def processContent(contentOrg, replacements):
  patternArray = {}
  patterns = re.findall(patternRe, contentOrg)
  for pattern in patterns:

    # Removing from variable name any "not found" string and
    # the characters that delimits the placeholder.
    variable=pattern.replace(notFoundString, "")[2:-2]

    try:
      # replacements can contain any type.  Converting to string.
      value = str(replacements[variable])

      # Now escaping any "\" with "\\" and replacing new lines "\n"
      # with "\ \n" so that the property files contains multiple lines following
      # Java properties files convention.
      # http://docs.oracle.com/javase/8/docs/api/java/util/Properties.html
      # Disabling this as we do not want this to be done here.
      #value = value.replace("\\", "\\\\").replace("\n", " \\\n")


      trace("  Replacing " + pattern + " with '" + value + "'.")
      patternArray[re.escape(pattern)] = value

    except KeyError:
      trace("  " + pattern + " not found.")
      patternArray[re.escape(pattern)] = "[[" + variable + notFoundString + "]]"

  #for pattern, value in patternArray.iteritems():

  # Clever and efficient algorithm used to replace all Strings in the file.
  # From:  http://stackoverflow.com/questions/6116978/python-replace-multiple-strings
  if len(patternArray) > 0:
    pattern = re.compile("|".join(list(patternArray.keys())))
    contentNew = pattern.sub(lambda m: patternArray[re.escape(m.group(0))], contentOrg)
  else:
    contentNew = contentOrg

  if contentOrg == contentNew:
    trace("  Content has not been changed.")
    return None
  else:
    return contentNew


# ────────────────────────────────────────────────────────────────────────────
def quiet():
  quiet=True 



# ────────────────────────────────────────────────────────────────────────────
# Execute the code, but only if this script has been called.
# If it was imported, do nothing.
if __name__ == "__main__":
  inputFilenames, outputFilename, replacements = parseArgs(sys.argv[1:])

  for inputFilename in inputFilenames:
    processFile(inputFilename, outputFilename, replacements)
