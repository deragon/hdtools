#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Defining encoding explained at http://www.python.org/dev/peps/pep-0263/

# Copyright 2000-2021 Hans Deragon - GPL 3.0 licence.
#
# Hans Deragon (hans@deragon.biz) owns the copyright of this code.
#
# It is released under the GPL 3 licence which can be found at:
#
#     https://www.gnu.org/licenses/gpl-3.0.en.html

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
import re
import subprocess

# os.path.realpath(os.curdir) # Current directory, canonical form.

script_path=os.path.dirname(sys.argv[0])
script_name=os.path.basename(sys.argv[0])

script_path_abs=os.path.realpath(script_path)

script_nameandpath_abs=script_path_abs + os.sep + script_name

# Regular expression comes from:  
# http://stackoverflow.com/questions/6416065/c-sharp-regex-for-file-paths-e-g-c-test-test-exe
winpath_regex=re.compile('^(?:[a-zA-Z]\:|\\[\w.]+\[\w.$]+)\\(?:[\w]+\)*\w([\w.])+$')
winpath_regex=re.compile("^[a-zA-Z]\:.*")

try:
  script_name_base=script_name.rsplit('.', 1)[0] # Extension found.
except IndexError:
  script_name_base=script_name # There is no extension.

script_path_abs_parent=os.path.dirname(script_path_abs)

command=re.sub("^hd", "", script_name)
command=re.sub("^svn$", "/usr/bin/svn", command)

for arg in sys.argv[1:]:
  matches = winpath_regex.match(arg)
  if matches != None:
    print "Path found: " + arg
    arg = subprocess.check_output(['acygpath', arg]).strip()

  command = command + " '" + arg + "'"

# Log, for debugging.
with open("/tmp/" + script_name + ".log", "a") as myfile:
  myfile.write("ARGS:  " + str(sys.argv) + "\n")
  myfile.write("CMD:   " + command + "\n")

os.system(command)
