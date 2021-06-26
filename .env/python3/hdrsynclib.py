#!/usr/bin/env python
# coding=UTF-8

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

from hdrsyncsoft import *
from hdrsync import *
import errno
import re
import os
import os.path
import copy

import socket

hostname = socket.gethostname()
fqdn = socket.getfqdn()
userid = "hans"

services = {}


def appendHDRsyncDirectory(id, site, sName):
    hdrsync = services[id]
    relations = hdrsync.getRelations()
    directories = relations[0].getDirectories()
    directories.append(HDRsyncDirectory(site, sName))


def isHostname(hostnameToTest):
    return hostname.lower() == hostnameToTest.lower()


def testHome():
    return isHostname("voxel001")


def testLaptop():
    return hostname[0:4] == "hans" or \
        hostname[0:4] == "snah" or \
        hostname == "demloka"

#         hostname      == "sitari"   or \
#         hostname      == "sittra"
#         hostname      == "ritoa"    or \
#         hostname      == "jolitari" or \
#         hostname      == "nutari1"  or \


def testWork():
    return not testHome() and not testLaptop() and fqdn.find("ericsson.se") != -1


sExcludePackages = ["--exclude", "*.rpm", "--exclude", "*.tar*"]
sExcludeBinaries = ["--exclude", "*.pyc", "--exclude", "*.class*"]
sExcludeBadBlocks = ["--exclude", "*badblocks"]

sExclude = sExcludePackages + sExcludeBinaries + sExcludeBadBlocks

# hdLmwcSite   = HDRsyncSite("lmwc", "tw" , "fw", \
#                  "lmwc", "lmw.lmc.ericsson.se", False)
hdWorkVmSite = HDRsyncSite("Work vm", "tv", "fv",
                           "hans", "hansderagon2", testHome())
hdHomeSite = HDRsyncSite("home server", "th", "fh",
                         "${HD_HOME_USERNAME}", "${HD_HOME_SERVER}", testHome())
# Android n'a pas bash...  Ça ne sert à rien de transférer l'environnement.
# hdAndroidPhone = HDRsyncSite("androi phone", "ta" , "fa", \
#                 "doesnotmatter", "192.168.43.1", testHome())
hdHomeSiteLyne = HDRsyncSite("home server", "th", "fh",
                             "lyne", "${HD_HOME_SERVER}", testHome())
hdLaptopSite = HDRsyncSite("laptop", "tl", "fl",
                           "${LAPTOPUSERNAME}", "${LAPTOPHOSTNAME}", testLaptop())
# For work site, hostname = <ASK> to force asking of the server.
hdWorkSite = HDRsyncSite("work", "tw", "fw",
                         "${WORKUSERNAME}", "<ASK>", testWork())
hdLocalSite = HDRsyncSite("local", "tz", "fz",
                          "${USER}", "localhost", True)

# hdCorpSite   = HDRsyncSite("Axa", "ta" , "fa", \
# "deragh01", None, false)

# All devices in /sys/block/
# Check `cat /sys/block/*/removable` for list of removable drives.
# Compare with /proc/mounts to figure out which are available.
extrasites = {}
index = 0
try:
    for mountpoint in os.listdir("/media"):
        mountpoint = "/media/" + mountpoint
        if not os.path.islink(mountpoint) and os.path.ismount(mountpoint):
            index += 1
            debug("Adding extra site:  " + mountpoint)
            extrasites[
                HDRsyncSite("external device " + mountpoint,
                            "t" + str(index), "f" + str(index),
                            None, None, False)] = mountpoint
except OSError as oserror:
    if oserror.errno != errno.ENOENT:  # No such file or directory
        raise

hdrsync = HDRsync("env", "Copying environment files",
                  [HDRsyncDirRelation(
                      [HDRsyncDirectory(hdHomeSite,     "/vol/data/base/home/hans/Seafile/Hans/"),
                       HDRsyncDirectory(hdLocalSite,    "${HOME}"),
                       HDRsyncDirectory(hdLaptopSite,   "${LAPTOPHOME}/hans/Seafile/Hans"),
                       HDRsyncDirectory(hdWorkVmSite,   "/home/hans"),
                       #        HDRsyncDirectory(hdAndroidPhone, "< NOT SET >"),
                       ],
                      [".hans.deragon"]
                  )
                  ]
                  )
hdrsync.setOptions(sExclude)
services[hdrsync.name] = hdrsync

# hdrsync = HDRsync("ericsson", "Copying Ericsson files",
#   [ HDRsyncDirRelation(
#       [ HDRsyncDirectory(hdHomeSite,   "/vol/data2/work/hp"),
#         HDRsyncDirectory(hdLocalSite,  "${HDENVBASE}"),
#         HDRsyncDirectory(hdWorkSite,   "/home/${WORKUSERNAME}/.hansderagon"),
#         HDRsyncDirectory(hdLaptopSite, "${LAPTOPHOME}") ],
#       [ ".ericsson" ]
#     )
#   ]
# )
# hdrsync.setOptions(sExclude)
# services[hdrsync.name] = hdrsync
#
# hdrsync = HDRsync("ericssonprivate", "Copying Ericsson private files",
#   [ HDRsyncDirRelation(
#       [ HDRsyncDirectory(hdHomeSite,   "/vol/data2/work/hp"),
#         HDRsyncDirectory(hdLocalSite,  "${HOME}"),
#         HDRsyncDirectory(hdWorkSite,   "/home/${WORKUSERNAME}"),
#         HDRsyncDirectory(hdLaptopSite, "${LAPTOPHOME}") ],
#       [ ".ericsson2" ]
#     )
#   ]
# )
# hdrsync.setOptions(sExclude)
# services[hdrsync.name] = hdrsync

hdrsync = HDRsync("home", "Copying Home directory",
                  [HDRsyncDirRelation(
                      [HDRsyncDirectory(hdHomeSite,   "/vol/data/base/home/" + hostname),
                       HDRsyncDirectory(hdLocalSite,  "${HOME}/.."),
                       HDRsyncDirectory(hdLaptopSite, "${LAPTOPHOME}/..")],
                      [userid]
                  )
                  ]
                  )
hdrsync.setOptions(sExclude)
services[hdrsync.name] = hdrsync

hdrsync = HDRsync("pers", "Copying Personal directory",
                  [HDRsyncDirRelation(
                      [HDRsyncDirectory(hdHomeSite,   "/vol/data/base/home/hans/Desktop"),
                       HDRsyncDirectory(hdLocalSite,  "${HOME}"),
                       HDRsyncDirectory(hdLaptopSite, "${LAPTOPHOME}")],
                      ["Personnel"]
                  ),
                      HDRsyncDirRelation(
                      [HDRsyncDirectory(hdHomeSite,   "/vol/data/base/home/hans/.kde/share/apps"),
                       HDRsyncDirectory(
                           hdLocalSite,  "${HOME}/.kde/share/apps"),
                       HDRsyncDirectory(hdLaptopSite, "${LAPTOPHOME}/.kde/share/apps")],
                      ["korganizer"]
                  )
                  ]
                  )
hdrsync.setOptions(sExclude)
services[hdrsync.name] = hdrsync

hdrsync = HDRsync("perslyne", "Copying Lyne's Personal directory",
                  [HDRsyncDirRelation(
                      [HDRsyncDirectory(hdHomeSiteLyne, "/vol/data/base/home/lyne"),
                       HDRsyncDirectory(hdLaptopSite, "/sp/home/lyne")],
                      ["Personnel"]
                  ),
                  ]
                  )
hdrsync.setOptions(sExclude)
services[hdrsync.name] = hdrsync

hdrsync = HDRsync("pidgin", "Copying Pidgin files",
                  [HDRsyncDirRelation(
                      [HDRsyncDirectory(hdHomeSite,   "/vol/data/base/home/hans"),
                       HDRsyncDirectory(hdLaptopSite, "${LAPTOPHOME}"),
                       HDRsyncDirectory(hdWorkSite,   "/home/${WORKUSERNAME}")],
                      [".gaim", ".purple"]
                  )
                  ]
                  )
hdrsync.setOptions(sExclude)
services[hdrsync.name] = hdrsync

hdrsync = HDRsync("pictures", "Copying Pictures directory",
                  [HDRsyncDirRelation(
                      [HDRsyncDirectory(hdHomeSite,   "/vol/media"),
                       HDRsyncDirectory(hdLocalSite,  "${HOME}"),
                       HDRsyncDirectory(hdLaptopSite, "${LAPTOPHOME}")],
                      ["Pictures"]
                  ),
                  ]
                  )
hdrsync.setOptions(sExclude)
services[hdrsync.name] = hdrsync

# hdrsync = HDRsync("hp", "Copying HP directory",
#  [ HDRsyncDirRelation(
#      [ HDRsyncDirectory(hdHomeSite,   "/perm/users/${HOMEUSERNAME}/Desktop"),
#        HDRsyncDirectory(hdLocalSite,  "${HOME}/Desktop"),
#        HDRsyncDirectory(hdWorkSite,   "/home/${WORKUSERNAME}/Desktop"),
#        HDRsyncDirectory(hdLaptopSite, "${LAPTOPHOME}/Desktop") ],
#      [ "hp" ]
#    )
#  ]
# )
# hdrsync.setOptions(sExclude)
#services[hdrsync.name] = hdrsync

# hdrsync = HDRsync("gnome", "Copying Gnome themes and icons",
#  [ HDRsyncDirRelation(
#      [ HDRsyncDirectory(hdHomeSite,   "/perm/users/${HOMEUSERNAME}"),
#        HDRsyncDirectory(hdLocalSite,  "${HOME}"),
#        HDRsyncDirectory(hdWorkSite,   "/home/${WORKUSERNAME}"),
#        HDRsyncDirectory(hdLaptopSite, "${LAPTOPHOME}") ],
#      [ ".icons", ".themes", ".gnome2/nautilus-scripts" ]
#    )
#  ]
# )
# hdrsync.setOptions(sExclude)
#services[hdrsync.name] = hdrsync

hdrsync = HDRsync("gpg", "Copying GPG",
                  [HDRsyncDirRelation(
                      [HDRsyncDirectory(hdHomeSite,   "/vol/data/base/home/hans"),
                       HDRsyncDirectory(hdLocalSite,  "${HOME}"),
                       HDRsyncDirectory(hdLaptopSite, "${LAPTOPHOME}")],
                      [".gnupg"]
                  )
                  ]
                  )
hdrsync.setOptions(sExclude + ["--exclude=random_seed"])
services[hdrsync.name] = hdrsync

hdrsync = HDRsync("firefox", "Copying Firefox files",
                  [HDRsyncDirRelation(
                      [HDRsyncDirectory(hdHomeSite,   "${FIREFOX_ACCOUNT_HOME}"),
                       HDRsyncDirectory(hdLocalSite,  "${FIREFOX_ACCOUNT}"),
                       HDRsyncDirectory(
                           hdWorkSite,   "${FIREFOX_ACCOUNT_ERICCSON}"),
                       HDRsyncDirectory(hdLaptopSite, "${FIREFOX_ACCOUNT}")],
                      ["places.sqlite", "bookmarks.html", "gm_scripts",
                       "extensions", "user.js"]
                  )
                  ]
                  )
hdrsync.setOptions(sExclude)
services[hdrsync.name] = hdrsync

hdrsync = HDRsync("thunderbird", "Copying Thunderbird files",
                  [HDRsyncDirRelation(
                      [HDRsyncDirectory(hdHomeSite,   "${THUNDERBIRD_ACCOUNT_HOME}"),
                       HDRsyncDirectory(
                           hdLocalSite,  "${THUNDERBIRD_ACCOUNT}"),
                       #HDRsyncDirectory(hdWorkSite,   "${THUNDERBIRD_ACCOUNT_ERICCSON}"),
                       HDRsyncDirectory(hdLaptopSite, "${THUNDERBIRD_ACCOUNT}")],
                      ["abook.mab", "extensions", "cert8.db", "key3.db"]
                  )
                  ]
                  )
hdrsync.setOptions(sExclude)
services[hdrsync.name] = hdrsync

hdrsync = HDRsync("chrome", "Copying Google Chrome files",
                  [HDRsyncDirRelation(
                      [HDRsyncDirectory(hdHomeSite,   "${HD_CHROME_ACCOUNT_HOME}"),
                       HDRsyncDirectory(hdLocalSite,  "${HD_CHROME_ACCOUNT}"),
                       HDRsyncDirectory(hdLaptopSite, "${HD_CHROME_ACCOUNT}")],
                      ["."]
                  )
                  ]
                  )
hdrsync.setOptions(sExclude)
services[hdrsync.name] = hdrsync

# hdrsync = HDRsync("devel", "Copying Development files",
#   [ HDRsyncDirRelation(
#       [ HDRsyncDirectory(hdHomeSite, "/vol/data2/work/hp/devel"),
#         HDRsyncDirectory(hdWorkSite, "/lmw/devel"),
#         HDRsyncDirectory(hdLaptopSite, "${LAPTOPHOME}/devel") ],
#       [ "apt-repo", "lmwf", "ksimagebuilder", "lmwreplica",
#         "osip", "rpmbuildacroread", "rpmbuildcc", "lmwdoc", "osi", "lmwu",
#         "lmwrsync", "lmwplti", "mwencryptmail", "mwlib" , "lmw11-12",
#         "lkp", "sudowrapper" ]
#     )
#   ]
# )
# hdrsync = HDRsync("devel", "Copying Development files",
#   [ HDRsyncDirRelation(
#       [ HDRsyncDirectory(hdHomeSite, "/vol/data2/work/hp"),
#         HDRsyncDirectory(hdWorkSite, "/lmw"),
#         HDRsyncDirectory(hdTuxSite,  "/export/lmw/hans.deragon"),
#         HDRsyncDirectory(hdLaptopSite, "${LAPTOPHOME}") ],
#       [ "devel" ]
#     )
#   ]
# )
# hdrsync.setOptions(sExclude)
# services[hdrsync.name] = hdrsync
#
# hdrsync = HDRsync("backgrounds", "Copying Backgrounds images",
#   [ HDRsyncDirRelation(
#       [ HDRsyncDirectory(hdHomeSite, "/vol/data2/images"),
#         HDRsyncDirectory(hdLaptopSite, "${LAPTOPHOME}/Desktop/fun") ],
#       [ "backgrounds" ]
#     )
#   ]
# )
# hdrsync.setOptions(sExclude)
# services[hdrsync.name] = hdrsync

hdrsync = HDRsync("hddeveltools", "Copying personal development tools.",
                  [HDRsyncDirRelation(
                      [HDRsyncDirectory(hdHomeSite, "/perm"),
                       HDRsyncDirectory(hdLaptopSite, "${LAPTOPHOME}/pers")],
                      ["develtools"]
                  )
                  ]
                  )
hdrsync.setOptions(sExclude)
services[hdrsync.name] = hdrsync

hdrsync = HDRsync("valueline", "Copie des Value Lines",
                  [HDRsyncDirRelation(
                      [HDRsyncDirectory(hdHomeSite, "/vol/data/base/home/hans/Desktop"),
                       HDRsyncDirectory(hdLaptopSite, "${LAPTOPHOME}/Desktop")],
                      ["ValueLine"]
                  )
                  ]
                  )
hdrsync.setOptions(sExclude)
services[hdrsync.name] = hdrsync

hdrsync = HDRsync("games", "Copying games.",
                  [HDRsyncDirRelation(
                      [HDRsyncDirectory(hdHomeSite,   "/vol/data/base/home/hans"),
                       HDRsyncDirectory(hdLaptopSite, "${LAPTOPHOME}")],
                      ["oolite-saves", ".Oolite"]
                  )
                  ]
                  )
services[hdrsync.name] = hdrsync
hdrsync.setOptions(sExclude)

hdrsync = HDRsync("sp-subset1", "Copying /sp subset 1.",
                  [HDRsyncDirRelation(
                      [HDRsyncDirectory(hdLocalSite, "/sp"),
                       HDRsyncDirectoryMedia("/sp")],
                      ["backgrounds", "gnome-themes", "home", "misc", "software"]
                  )
                  ]
                  )
hdrsync.setOptions(["--archive", "--exclude", ".gvfs"])
services[hdrsync.name] = hdrsync

# hdrsync = HDRsync("", "",
#   [ HDRsyncDirRelation(
#       [ HDRsyncDirectory(hdHomeSite,   ""),
#         HDRsyncDirectory(hdLocalSite,  ""),
#         HDRsyncDirectory(hdWorkSite,   ""),
#         HDRsyncDirectory(hdLaptopSite, "") ],
#       [ ]
#     )
#   ]
# )
# services[hdrsync.name] = hdrsync

# FUNCTIONS ============================================================


def run(servicesToRun):
    selection = None
    rsyncCmd = RsyncCmd()
    args = rsyncCmd.readArgOptions()
    if servicesToRun == None:
        servicesToRun = args

    if type(servicesToRun) == type('str'):
        servicesToRun = [servicesToRun]

    # print services
    for serviceToRun in servicesToRun:
        debug("serviceToRun = " + serviceToRun, 10)
        try:
            hdrsync = services[serviceToRun]
            hdrsync.setRsyncCmd(rsyncCmd)
            selection = hdrsync.run(previousSelection=selection)
            rsyncCmd.resetOptions()
        except IndexError:
            print("Service " + serviceToRun + " not available.")
