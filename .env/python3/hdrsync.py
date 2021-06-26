#!/usr/bin/env python
# -*- coding: utf-8 -*-

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

# Basic, bottom class that only calls 'rsync'.  It does nothing else.

import sys
import os
import getopt
import __main__

from hdlib2 import *

extraParameters = {}


class RsyncCmd:

    def __init__(self):
        self.scriptname = os.path.basename(sys.argv[0])
        self.options = []
        self.cmdlineoptions = []
        self.direction = None
        __main__.gDryRun = False
        #debug("HDRsync.__init__():  self.options=" + str(self.options), 20)

    def usage(self):
        print("""
Usage:  """ + self.scriptname + """ [-h|--help] [-d|--dry-run] [-z|--debug]
""")
        sys.exit(0)

    def readArgOptions(self):
        global extraParameters

        try:
            opts, args = getopt.gnu_getopt(
                sys.argv[1:], "hdz:", ["help", "dry-run", "debug="])
        except getopt.GetoptError:
            # print help information and exit:
            self.usage()

        for option, arg in opts:
            debug("argv option = " + option, 20)
            if option in ("-h", "--help"):
                self.usage()
                sys.exit()
            elif option in ("-d", "--dry-run"):
                print("\nDry run mode enabled.\n")
                __main__.gDryRun = True
                self.cmdlineoptions = ["--dry-run"]
            elif option in ("-z", "--debug"):
                debug.setLevel(int(arg))
                print("Debug level set to " + arg)

        #debug("HDRsync.readArg():  self.options=" + str(self.options), 20)
        self.resetOptions()

        debug("Arguments left:  " + str(args), 3)

        regex = re.compile("([^=]+)=([^=]+)")
        for arg in args:
            match = regex.match(arg)
            if match:
                extraParameters[match.group(1)] = match.group(2)
            else:
                self.direction = arg

        return args

    def setOptions(self, options):
        if options == None or options == '':
            return
        debug("HDRsync.setOptions(" + str(options), 20)
        self.options = self.options + options
        debug("HDRsync.setOptions():  self.options=" + str(self.options), 20)
        #debug("HDRsync.setOptions():  self.options >>" + self.options + "<<", 20)

    def resetOptions(self):
        self.options = self.cmdlineoptions

    def perform(self, src, dst, user, sshkey, sshport=22):
        debug("HDRsync.perform: src = " + str(src), 50)
        debug("HDRsync.perform: dst = " + str(dst), 50)
        rsh = []
        if not user == None:
            if sshkey == None:
                sshkey = ""
            rsh = ["--rsh", "\"ssh -l " + str(user) + str(sshkey) + "\""]

        debug("HDRsync.setOptions(" + str(self.options) + ")", 20)
        cmd = ["rsync", "--rsh=/usr/bin/ssh -p " + str(sshport), "--links",
               "--hard-links", "--progress",
               "--delete-after", "--times", "--recursive",
               "--compress", "--perms"] + self.options + \
            rsh + src + dst

        return execute(command=cmd,
                       logfile="/tmp/rsync-" + os.environ["USER"] + ".log", printLines=True)


######################################################################
# MAIN
# rsyncCmd = RsyncCmd() # rsyncCmd.readArgOptions() #
# menulines = [ "Transfer from A to B", \
#               "Transfer from B to C", \
#               "Transfer from C to A" ]
#
# menu = HDMenu("Test menu", menulines, rsyncCmd.key)
# selection = menu()
# rsyncCmd.perform()
# print "Selection = " + str(selection)
