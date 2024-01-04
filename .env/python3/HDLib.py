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

import types
import array
import subprocess
import sys
import os
import re
import traceback
import time
import inspect
import __main__
import fcntl
import socket
import struct
import shlex
import chardet
from subprocess import *
from HDLibPath import *


"""
  run()

    It is easier to make use of run() instead of execute() because the
    'command' parameter can be a string with the application and arguments
    to run.

  command:

    String with all of the arguments.  Thus a valid command can be:

      find . -name "*Nice report*" -type f

  flatOutput:

    flatOutput, when set to True, will cause the returned output to be a
    single string, the result of the concatenation of all lines of the output
    with no linefeed or carriage return.  Useful when one wants to parse the
    output.

"""


def run(command, logfile=None, logfileAppend=True,
        exitOnFailure=False, test=False, callback=None,
        stdinText=None, printLines=False, flatOutput=False):

    hdlibDebug.function(
        ">>" + command +
        "<<, logfile=" + str(logfile) +
        ", logfileAppend=" + str(logfileAppend) +
        ", exitOnFailure=" + str(exitOnFailure) +
        ", test=" + str(test) +
        ", callback=" + str(callback) +
        ", stdinText=" + str(stdinText) +
        ", printLines=" + str(printLines) +
        ", flatOutput=" + str(stdinText))

    command=shlex.split(command)
    return execute(
        command=command,
        logfile=logfile,
        logfileAppend=logfileAppend,
        exitOnFailure=exitOnFailure,
        test=test,
        callback=callback,
        stdinText=stdinText,
        printLines=printLines,
        flatOutput=flatOutput)


def execute(command, logfile=None, logfileAppend=True,
            exitOnFailure=False, test=False, callback=None,
            stdinText=None, printLines=False, flatOutput=False):
    global hdlibDebug

    hdlibDebug.function(
        "'" + " ".join(command) +
        "', logfile=" + str(logfile) +
        ", logfileAppend=" + str(logfileAppend) +
        ", exitOnFailure=" + str(exitOnFailure) +
        ", test=" + str(test) +
        ", callback=" + str(callback) +
        ", stdinText=" + str(stdinText))

    if not hdlibDebug.execution:
        hdlibDebug("Dry-run:  >>" + commandToString(command) +
                   "<< not executed since hdlibDebug.execution == False.")
        return 0, ""

    if test:
        hdlibDebug("Dry-run:  >>" + commandToString(command) + "<<")
        return 0, ""

    debug("HDLib.execute command=" + str(command))
    PopenInstance = Popen(command, bufsize=0,
                          stdin=PIPE, stdout=PIPE, stderr=STDOUT, close_fds=True)

    stdin = PopenInstance.stdin

    # Old way of doing.  Now maybe obsolete, but left here as documentation
    # for prosperity.
    #
    #   PopenInstance=popen2.Popen4(command, 0)
    #   stdin = PopenInstance.tochild
    #   stdoutAndStderr = PopenInstance.fromchild

    if type(stdinText) == bytes:
        stdin.write(stdinText)

    stdin.close()

    stdoutAndStderr = PopenInstance.stdout

    loghandle = None
    if logfile != None:
        loghandle = open(logfile, 'w')
        loghandle.write(command[0] + " " + command[1])

    lines = []
    while True:
        line = stdoutAndStderr.readline()

        if not line:
            break

        #print("type of line:      " + str(type(line)))
        #print("line:      " + str(line))

        # Detect filesystem encoding being used
        # See:  https://serverfault.com/questions/82821/how-to-tell-the-language-encoding-of-a-filename-on-linux
        #charSetDetected = chardet.detect(line)['encoding']
        # Comment by Hans Deragon (hans@deragon.biz), 2018-04-25 17:51:57 EDT
        # Hard code ici car sous Linux, sous ext4, charSetDetect parfois détecte
        # faussement 'windows-1252'!
        charSetDetected = 'utf8'
        line = line.decode(charSetDetected)
        #print("type of line:      " + str(type(line)))
        #print("line:      " + str(line))

        #print("type of line:      " + str(type(line)))
        #print("line:      " + line)
        stdoutAndStderr.flush()
        lines.append(line)
        if printLines:
            print(line, end='')

        if callback:
            # If the callback function returns False, that means we have to
            # stop the execution.

            if not callback(line):
                break

        if loghandle:
            loghandle.write(line)

    if loghandle:
        loghandle.close()

    stdoutAndStderr.close()
    exitstatus = PopenInstance.wait()
    if flatOutput:
        lines = " ".join(lines).replace("\n", "").replace("\r", "")
    return exitstatus, lines


whiteSpacePatterns = re.compile('[\s|\(|\)]')

# This functon takes a list used for a command to execute and returns a string
# representation of it with arguments containing whitespaces quoted.


def commandToString(cmd):
    cmdStr = []
    for arg in cmd:

        # Escaping the apostrophe (').
        arg = arg.replace("'", "'\\''")

        # If
        if bool(whiteSpacePatterns.search(arg)):
            arg = "'" + arg + "'"

        cmdStr.append(arg)

    return " ".join(cmdStr)


class Debug:

    BASELEVEL = 0
    FUNCTIONLEVEL = 5
    PREFIX = "DEBUG"

    def __init__(self, level, execution=True):
        # print "Debug.__init__()"
        self.subscribed = []
        self.stdout = sys.stdout  # saving original stdout.
        self.setLevel(level)
        self.setExecution(execution)

    def __call__(self, entity, level=1, newline=True):
        if self.level >= level + self.BASELEVEL:
            print(self.PREFIX + ":  " + str(entity))
            print(self.PREFIX + ":  " + indent(str(entity), 8, False), end=' ')
            if newline:
                print("\n", end=' ')
            sys.stdout.flush()

    def setLevel(self, level):
        # print "Debug.setLevel(" + str(level) + ")"
        self.level = level
        for subscribed in self.subscribed:
            subscribed.setLevel(level)

    def setExecution(self, execution):
        self.execution = execution

    def function(self, *args):
        string = ""
        extrastring = ""
        level = 0

        for arg in args:
            if type(arg) == int:
                level = arg
            else:
                if string == "":
                    string = str(arg)
                else:
                    extrastring = str(arg)

        if self.level >= level + self.BASELEVEL:
            tb = traceback.extract_stack()
            function = tb[-2][2]
            cf = inspect.getouterframes(inspect.currentframe())
            cf = cf[1]
            frame = cf[0]
            try:
                classname = frame.f_locals['self'].__class__
                classname = str(classname) + "."
            except KeyError:
                classname = ""
#       #frame=inspect.stack()[-3]
            # debugprint(inspect.getmembers(frame))
            # code=frame.f_code
            # debugprint(inspect.getmembers(code))
            # print "     cf = " + str(cf)
            # print "frame: " + str(inspect.getframeinfo(cf))
            # print traceback.format_list(tb)
            # classname=function.__class__
            output = classname + str(function) + "(" + str(string) + ")"
            if extrastring:
                output += " - " + extrastring
            self.__call__(output)

    def outputToFile(self, filename=None):
        if filename == None:
            sys.stdout = self.stdout
        else:
            sys.stdout = open(filename, 'w')

    def subscribe(self, debug):
        self.subscribed.append(debug)


class HDLibDebug(Debug):

    BASELEVEL = 20
    PREFIX = "HDLIB"

    def __init__(self, execution=True):
        Debug.__init__(self, debug.level, execution)
        debug.subscribe(self)


debug = Debug(0)
hdlibDebug = HDLibDebug()


def printMembers(object):
    HDLib.obj2print(inspect.getmembers(object))


def obj2print(object):
    print(obj2str(object))


def _obj2str_indent(indentation):
    string = ""
    for index in range(0, indentation[0]):
        string = string + "  "
    for index in range(indentation[0], indentation[1]):
        string = string + "│ "

    return string


def obj2str(object, indentation=[0, 0], output=""):

    if type(object) == list or \
       type(object) == tuple or \
       type(object) == dict:

        output = output+str(type(object))+"\n"

        if type(object) == list or \
           type(object) == tuple:
            for index in range(0, len(object)):
                output = output + _obj2str_indent(indentation)
                if index == len(object)-1:
                    branchchar = "└ #"
                    indentation[0] = indentation[0]+1
                else:
                    branchchar = "├ #"
                output = output + branchchar + str(index).rjust(2) + " ▶ "
                output = obj2str(object[index],
                                 [indentation[0], indentation[1]+1], output)
        elif type(object) == dict:
            index = 0
            for key in list(object.keys()):
                index = index+1
                output = output+_obj2str_indent(indentation)
                if index == len(object):
                    branchchar = "└ "
                    indentation[0] = indentation[0]+1
                else:
                    branchchar = "├ "
                output = output + branchchar + key + " ▶ "
                output = obj2str(object[key],
                                 [indentation[0], indentation[1]+1], output)
    else:
        output = output+str(object)+"\n"

    return output


def verbose(entity):
    if __main__.gVerboseMode:
        print(str(entity))


# findExistingPath moved to HDLib.path.py
# def findExistingPath(listOfPaths):
#   for path in listOfPaths:
#     if os.path.exists(path):
#       return path
#   return None


# fprint moved to HDLib.path.py
# # chmod is octal, like 0660.
# def fprint(filename, string, chmod=None):
#   handle=open(filename, 'w')
#   if chmod != None:
#     os.chmod(filename, chmod)
#   print >>handle, string
#   handle.close()


def removeNewLines(string):
    return string.replace("\n", "")


"""
HDLib.evalVariables("Today is ${DATE}.", { "Date" : str(date) } )
"""


def evalVariables(string, variables):
    # for variable in re.compile("([^\\]\${\w+})").findall(string):
    for variable in re.compile("(\${\w+})").findall(string):
        try:
            string = string.replace(variable, variables[variable[2:-1]])
        except KeyError:
            pass

    return string


osdata = None


def osstrip(value):
    pass


def oscompare(oscomparedata):
    debug("oscompare(" + str(oscomparedata))
    reoperators = re.compile("^(=|>|>=|<|<=)(.*)")
    osdata = osdetect()

    for key in list(oscomparedata.keys()):
        if key in oscomparedata:
            mo = reoperators.search(oscomparedata[key])
            if mo:
                operator = mo.group(1)
                value = mo.group(2)
                if len(osdata[key]) == 0:
                    return False

                evalstr = str(osdata[key] + operator + value)
                #debug("evalstr = " + evalstr)
                rv = eval(evalstr)
                if not rv:
                    return False
            else:
                if oscomparedata[key] != osdata[key]:
                    return False

    return True


def osdetect():
    global osdata

    if osdata:
        return osdata
    else:
        osdata = {}

    osdetectpath = findExistingPath([
        "/var/corp/lhd/lhdc/common/osdetect",
        "/sp/home/hans/devel/lhdf/lhdf.trunk/lib/osdetect"])

    if osdetectpath == None:
        raise OSError(
            "HDLib:  Could not find 'osdetect' for identifying the OS.")

    osdetectcmd = osdetectpath + " -p"
    exitstatus, lines = execute(osdetectcmd)

    if exitstatus > 0:
        raise Exception

    regexp = re.compile("LHDF_OS_(.*)=(.*)")
    for line in lines:
        mo = regexp.search(line)
        if mo:
            osdata[mo.group(1)] = mo.group(2)
        else:
            raise Exception

    return osdata


def indent(lines, level=2, indentFirstLine=True):
    """Indents the text passed as 'lines'

    lines can be of type 'str' or 'list'.
    """
    output = ""
    spaces = "                    "

    if type(lines) == bytes:
        #print("Indentation of bytes", 40)
        lines = lines.split('\n')

    if type(lines) == str:
        lines = [lines]

    for line in lines:
        #print("line = " + str(line))
        if indentFirstLine:
            output = output + spaces[0:level] + line + '\n'
        else:
            output = output + line + '\n'
            indentFirstLine = True

    return output.rstrip()


def findPathMatch(arg1, arg2):
    if len(arg1) >= len(arg2):
        longest = arg1
        shortest = arg2
    else:
        longest = arg2
        shortest = arg1

    # print "longest = " + longest
    # print "shortest = " + shortest

    start = 0
    matchindex = 0
    while 1:
        index = string.find(longest, "/", start) + 1
        # print "Comparing " + longest[0:index] + " with " +  shortest[0:index] + \
        #       "  - start == " + str(start) + "  - index == " + str(index)
        if longest[0:index] != shortest[0:index]:
            break
        else:
            matchindex = index - 1
            start = index

    # print "Returning " + longest[0:matchindex]
    return longest[0:matchindex]

# From http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/439094
#
# Return the IP address corresponding to the interface.
# Usage:  getIpAddress('eth0')


def getIpAddress(ifname):
    socketObject = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    return socket.inet_ntoa(fcntl.ioctl(
        socketObject.fileno(),
        0x8915,  # SIOCGIFADDR
        struct.pack('256s', ifname[:15])
    )[20:24])


# From http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/439093
#
# returns:  ['lo', 'eth0'] # for example
def allInterfaces():
    max_possible = 128  # arbitrary. raise if needed.
    bytes = max_possible * 32
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    names = array.array('B', '\0' * bytes)
    outbytes = struct.unpack('iL', fcntl.ioctl(
        s.fileno(),
        0x8912,  # SIOCGIFCONF
        struct.pack('iL', bytes, names.buffer_info()[0])
    ))[0]
    namestr = names.tostring()
    return [namestr[i:i+32].split('\0', 1)[0] for i in range(0, outbytes, 32)]


def allExternalIPs():
    ipaddresses = []
    for interface in allInterfaces():
        if interface == "lo":
            continue
        ipaddresses.append(getIpAddress(interface))
    return ipaddresses
