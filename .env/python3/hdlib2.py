# coding=utf-8

# ─ Copyright Notice ───────────────────────────────────────────────────
#
# Copyright 2000-2024 Hans Deragon - AGPL 3.0 licence.
#
# Hans Deragon (hans@deragon.biz) owns the copyright of this work.  It is
# released under the GNU Affero General public Picense which can be found at:
#
#     https://www.gnu.org/licenses/agpl-3.0.en.html
#
# ─────────────────────────────────────────────────── Copyright Notice ─

from HDLibPath import *
from HDLib import *
from hdgetch import *
import subprocess
import filecmp
import os
import random
import re
import shutil
import sys
import math
import __main__

# Global variables
gScriptName = os.path.basename(sys.argv[0])

HDEXITCODE_HELP = 254
HDEXITCODE_NOTIMPLEMENTED = 254

# print "hdlib.py"

# This function replaces all environement variables with their values.
# Variables MUST be enclosed in ${}.
#
# Ex:  evalEnv("/home/${USER}/Desktop/$APPL") => /home/hans/Desktop/$APPL
#


def evalEnv(listOrString, warning=False, variables=os.environ):
    if type(listOrString) == type(""):
        list = [listOrString]
    else:
        list = listOrString

    if list == None:
        return list

    # print "list: " + str(list)
    newlist = []
    for string in list:
        if string != None:
            for variable in re.compile(r'(\${[\w]+})').findall(string):
                # print "variable:  " + variable
                try:
                    string = string.replace(
                        variable, variables[variable[2:-1]])
                    # print "variables:  " + str(variables)
                    # print "string = " + string
                except KeyError:
                    if warning:
                        print("WARNING:  Could not evaluate variable " + variable + " in string " +
                              string + ".")
                    pass
        newlist.append(string)

    #debug("evalEnv():  newlist " + str(newlist), 50)
    # print "evalEnv():  newlist " + str(newlist)
    if type(listOrString) == type(""):
        return newlist[0]
    else:
        return newlist


sys.path[:0] = [evalEnv("${HDENVDIR}/python")]


HDFILECOPY = 1
HDFILERENAME = 2


def backupFile(file, extension=".bak", operation=HDFILECOPY):
    if extension[0] != ".":
        extension.insert(0, ".")

    index = 1
    backupfile = file + extension

    while True:
        if os.path.exist(backupfile):
            backupfile = file + "." + str(index) + extension
        else:
            break

    if operation == HDFILECOPY:
        print("backupfile():  HDFILECOPY operation not implemented.")
        sys.exit(100)
    elif operation == HDFILERENAME:
        os.rename(file, backupfile)
    else:
        print("backupfile():  " + str(operation) +
              " operation not supported.  Aborting.")
        sys.exit(200)

    return backupfile


def replaceFile(file, newfile):
    if cmp.cmp(file, newfile):
        return False

    backupfile = backupfile(file, operation=HDFILERENAME)
    shutil.copyfile(newfile, file)

    return True


def notImplemented():
    tb = traceback.extract_stack()
    function = str(tb[-2][2])
    file = str(tb[-2][0])
    print("ERROR:  " + function + "() not implemented.")
    print("        This function reside in " + file)
    print("        Aborting with exit code:  " + str(HDEXITCODE_NOTIMPLEMENTED))
    sys.exit(HDEXITCODE_NOTIMPLEMENTED)


def replaceStringsInFile(file, data):
    notImplemented()


def reverseString(string):
    returnstring = ""
    for index in range(len(string)-1, -1, -1):
        returnstring = returnstring + string[index]
    return returnstring


def randomString(length=16, limit="[a-zA-Z]"):
    regex = re.compile(limit)
    string = ""
    for index in range(length):
        while True:
            randchar = chr(random.randint(0, 255))
            debug("randchar = " + randchar, 10)
            if regex.match(randchar):
                debug("randchar matches:  " + randchar, 9)
                string = string + randchar
                break

    debug("randomString() returns \"" + string + "\".", 5)
    return string


def hashFromString(string):
    hash = 0
    for character in string:
        hash = + ord(character)
    return hash


def getEnv(variable):
    try:
        return os.environ[variable]
    except KeyError:  # Variable is not defined in the environment.
        return ""


# def TerminalCreation(numberX, numberY):
#  resX=commands.getoutput("hd-screen-resolution-x x")
#  resY=commands.getoutput("hd-screen-resolution-x y")

# class walkDirectory:
#   def __init__(directory, callback)
#
#
#   os.path.walk(directory, hdlib.visit, arg)
# def walkDirectory(directory, callback)
#   os.path.walk(directory, hdlib.visit, arg)

def walkRegEx(path, depth):
    for root, dirs, files in os.walk(path):
        print("root = " + root)
        print("dirs = " + str(dirs))
        print("files = " + str(files))


class HDMenuItem:

    def __init__(self, line, keySequence, item=None):
        """
      item is not used by the HDMenu* classes.  However, it is returned to
      the caller as the selection if this particular HDMenuItem was selected.

      This way, it is easier for the caller to trace which of the options
      has been selected by comparing it to an object it knows about.

    """
        self.line = line
        self.keySequence = keySequence
        self.item = item


class HDMenu:

    def __init__(self, title, hdmenuitems):
        self.title = title
        self.hdmenuitems = hdmenuitems
        self.selectedHDMenuItem = None

    def __call__(self):
        self.printMenu()
        self.readSelection()
        return self.selectedHDMenuItem.item

    def printMenu(self):
        # \r are necessary here at the end of each line printed to stdout, so that
        # under Cygwin, the list shows up properly.
        print("  " + self.title + "\n\r")
        index = 0
        for hdmenuitem in self.hdmenuitems:
            index = index+1
            print("  " + str(index) + ") "
                  + hdmenuitem.line
                  + " <" + hdmenuitem.keySequence + ">\r")
        print("  -) Clear selection\r")
        print("  q) Quit\r")

    def printPrompt(self, keySelection):
        self.clearLine()
        print("\r  Please select an option.  <<" +
              keySelection + ">>\r", end=' ')

    def readSelection(self):
        keySelection = ""
        print("\n  Please select an option.", end=' ')
        while True:
            key = getch()
            if key == "q":
                self.clearLine()
                print("  Quiting.\n\r")
                sys.exit(0)
            if key == "" or key == "-":
                keySelection = ""
                self.printPrompt(keySelection)
                # self.clearLine()
                # print "\r  Selection cleared.  ",
                continue

            self.selectedHDMenuItem = None

            keySelection += key
            # print "keySelection=>>" + keySelection + "<<\n"
            try:
                if ord(key) == 13 or \
                   len(keySelection) == int(math.log(len(self.hdmenuitems), 10))+1:

                    number = int(keySelection)
                    self.clearLine()
                    self.selectedHDMenuItem = self.hdmenuitems[number-1]
                else:
                    raise ValueError

            except ValueError:
                for hdmenuitem in self.hdmenuitems:
                    if hdmenuitem.keySequence == keySelection:
                        self.selectedHDMenuItem = hdmenuitem

            if ord(key) == 13:
                keySelection = ""
                self.printPrompt(keySelection)

            if self.selectedHDMenuItem != None:
                print("\r  You selected option -= " + self.selectedHDMenuItem.line +
                      " =-.  Please confirm (Y/N)\r", end=' ')
                yn = getch()
                if not yn == "y":
                    self.clearLine()
                    keySelection = ""
                else:
                    break

            self.printPrompt(keySelection)

        print()

        #debug("self.selectedHDMenuItem=" + str(self.selectedHDMenuItem), 5)
        return self.selectedHDMenuItem.item

    def clearLine(sefl):
        print("\r                                                                           \r", end=' ')
