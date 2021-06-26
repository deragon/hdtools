#!/usr/bin/env python

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

import os
import socket
import os.path
import __main__
import errno

import HDLib
from hdlib2 import *
from hdrsync import *


aMountedMedia = None


def askHostnameIfNeeded(hostname):
    if hostname == "<ASK>":
        print("Hostname not provided, please enter it:  ", end=' ')
        hostname = sys.__stdin__.readline().rstrip("\n\r")
    return hostname


def mountedMedia(sDirPrefix):
    global aMountedMedia

    if aMountedMedia == None:

        # All devices in /sys/block/
        # Check `cat /sys/block/*/removable` for list of removable drives.
        # Compare with /proc/mounts to figure out which are available.
        aMountedMedia = []
        index = 0
        try:
            for mountpoint in os.listdir("/media"):
                mountpoint = "/media/" + mountpoint
                if not os.path.islink(mountpoint) and os.path.ismount(mountpoint):
                    index += 1
                    if sDirPrefix != None:
                        if sDirPrefix[0] == "/":
                            separator = ""
                        else:
                            separator = "/"
                        mountpoint = mountpoint+separator+sDirPrefix

                    aMountedMedia.append(HDRsyncDirectory(
                        HDRsyncSite("external device " + mountpoint,
                                    "t" + str(index), "f" + str(index),
                                    None, None, False), mountpoint))
        except OSError as oserror:
            if oserror.errno != errno.ENOENT:  # No such file or directory
                raise

    return aMountedMedia


def raiseCommandError(statusCode, output, cmd):
    output = ('\n').join(output)
    print()
    output = ""
    #   if statusCode >> 8 == 24:
    #     # Error 24 is 'some files vanished before they could be transferred (code 24)'
    #     # No need for output in these circumstances.
    #     output = ""
    #   else:
    #     output = "\noutput:       " + str(output))
    raise RuntimeError("HD Rsync command failure." +
                       indent(
                           "\ncommand:      " + cmd +
                           "\nstatus code:  " + str(statusCode >> 8) + "/" +
                           hex(statusCode >> 8) +
                           " (" + str(statusCode) + "/" +
                           hex(statusCode) + ")" + output))
    print()


try:
    sshenvfilename = os.environ["HOME"] + \
        "/.ssh/env/" + socket.gethostname() + ".py"
    sshenvfd = open(sshenvfilename, 'r')
    sshenvdata = sshenvfd.read()
    sshenvfd.close()
    exec(sshenvdata)
except IOError as ioerror:
    if ioerror[0] != errno.ENOENT:
        raise ioerror

    pass  # Ignoring

# sys.path.insert(os.environ["HOME"] + "/.ssh/env")
# import socket.gethostname() + ".py"


def executeCommands(commands):
    notImplemented()
    for command in commands:
        cmd = "ssh hans@${HOMESERVER}"


class HDRsyncSite:

    def __init__(self, name, toKeys, fromKeys, username, hostname,
                 isCurrentSite=False):
        self.name = name
        self.toKeys = toKeys
        self.fromKeys = fromKeys
        self.isCurrentSite = isCurrentSite
        self.directory = None
        self.hdRsyncDirectory = None

        if username:
            self.username = evalEnv(username)
        else:
            self.username = None

        if hostname:
            tmphostname = evalEnv(hostname)
            self.hostname = tmphostname.split(":", 1)[0]
            try:
                self.port = tmphostname.split(":", 1)[1]
            except IndexError:
                self.port = 22

        else:
            self.hostname = None
            self.port = None

    def getDirectory(self):
        return self.directory

    def getHostname(self):

        if self.hostname == "<ASK>":
            try:
                self.hostname = extraParameters['hostname']
            except KeyError:
                None

        return self.hostname

    def getPort(self):
        return self.port

    def setDirectory(self, directory):
        self.directory = directory

    def setHDRsyncDirRelation(self, hdRsyncDirectory):
        self.hdRsyncDirectory = hdRsyncDirectory

    def __hash__(self):
        hash = hashFromString(self.name)
        #debug("HDRsyncSite:__hash__() - hash = " + str(hash), 30)
        return hash
        # return len(self.name)

    def __eq__(self, other):
        if other:
            return self.name == other.name
        else:
            return False

    def __str__(self):
        return "HDRsyncSite " + indent(
            "\nself.name             = " + str(self.name) +
            "\nself.toKeys           = " + str(self.toKeys) +
            "\nself.fromKeys         = " + str(self.fromKeys) +
            "\nself.isCurrentSite    = " + str(self.isCurrentSite) +
            "\nself.username         = " + str(self.username) +
            "\nself.hostname         = " + str(self.hostname) +
            "\nself.port             = " + str(self.port) +
            "\nself.directory        = " + str(self.directory) +
            "\nself.hdRsyncDirectory = " + str(self.hdRsyncDirectory))
#            str(self.toKeys) + ", " + \
#            str(self.fromKeys) +  ", " +\
#            str(self.isCurrentSite) + ")"

# class HDRsyncSiteDynamic(HDRsyncSite): # Obsolete; to delete.


class HDRsyncDirectory:

    def __init__(self, site, directory, postcommand=None, precommand=None):
        self.site = site
        self.directory = evalEnv(directory)
        self.precommand = evalEnv(precommand)
        self.postcommand = evalEnv(postcommand)

    def executePreCommands(self, relation):
        if self.precommand != None:
            self.executeCommands(self.precommand, "pre", relation)

    def executePostCommands(self, relation):
        if self.postcommand != None:
            self.executeCommands(self.postcommand, "post", relation)

    def executeCommands(self, commands, sType, relation):
        commands = HDLib.evalEnv(commands, {
            "directory": self.directory,
            "hostname":  self.site.getHostname(),
            "port":      self.site.getPort(),
            "username":  self.site.username})
        reLeaf = re.compile("\$\{leaf\}")
        if reLeaf.search(commands):
            for leaf in relation.leafDirs:
                print("leaf = " + leaf)
                commands = commands.replace("${leaf}", leaf)
                self.executeCommand(commands, sType)
        else:
            self.executeCommand(commands, sType)

    def __str__(self):
        return "HDRsyncDirectory" + indent(
            "\nself.site             = " + str(self.site) +
            "\nself.directory        = " + str(self.directory) +
            "\nself.precommand       = " + str(self.precommand) +
            "\nself.postcommand      = " + str(self.postcommand))

    def executeCommand(self, commands, sType):
        if not self.site.isCurrentSite:
            hostname = askHostnameIfNeeded(self.site.getHostname())
            port = self.site.getPort()
            cmd = "ssh " + self.site.username + "@" + \
                hostname + ":" + port + " \'"
        else:
            cmd = ""

        cmd = cmd + commands

        if not self.site.isCurrentSite:
            cmd = cmd + "'"

        debug(sType + "command=" + cmd)
        (statusCode, output) = \
            execute(command=cmd, printLines=False, test=__main__.gDryRun)
        output = string.join(output, '\n')

        if statusCode != 0:
            raiseCommandError(statusCode, output, cmd)


class HDRsyncDirectoryMedia(HDRsyncDirectory):
    def __init__(self, directory, postcommand=None, precommand=None):
        HDRsyncDirectory.__init__(
            self, None, directory, postcommand, precommand)


class HDRsyncDirRelation:

    TYPE_SRC = 0
    TYPE_DST = 1

    def __init__(self, aHDRsyncDirectory, leafDirs):
        self.mediaDirectory = None
        for index in range(0, len(aHDRsyncDirectory)):
            if aHDRsyncDirectory[index].__class__ == HDRsyncDirectoryMedia:
                self.mediaDirectory = aHDRsyncDirectory[index].directory
                # Removing the media site.
                aHDRsyncDirectory = aHDRsyncDirectory[0:index] + \
                    aHDRsyncDirectory[index+1:len(aHDRsyncDirectory)]

        self.aHDRsyncDirectory = aHDRsyncDirectory
        self.leafDirs = leafDirs
        self.localHDRsyncDirectory = None
        self.computeSites()
        #debug("self.aHDRsyncDirectory = " + str(self.aHDRsyncDirectory), 45)
        #debug("self.leafDirs= " + str(self.leafDirs))

    def getDirectories(self):
        return self.aHDRsyncDirectory

    def getSites(self):
        return self.sites

    def computeSites(self):
        self.sites = []
        for hdRsyncDirectory in self.aHDRsyncDirectory:
            if hdRsyncDirectory.site != None:  # Media Directory has site set to None.
                self.sites.append(hdRsyncDirectory.site)
                if hdRsyncDirectory.site.name == "local":
                    self.localHDRsyncDirectory = hdRsyncDirectory

    def getHDRsyncDirectoryFromSite(self, site):
        for hdRsyncDirQ in self.aHDRsyncDirectory:
            if hdRsyncDirQ.site == site:
                return hdRsyncDirQ
        raise Exception("BUG:  Could not find " + str(site.name))

    def getPath(self, site, sitetype, remote=False):
        # If the path is remote, it cannot be self.localdir by defintion.
        if not remote:
            if site.isCurrentSite:
                directory = self.getHDRsyncDirectoryFromSite(site).directory
            elif self.localHDRsyncDirectory != None:
                directory = self.localHDRsyncDirectory.directory
        else:
            directory = self.getHDRsyncDirectoryFromSite(site).directory
        if sitetype == HDRsyncDirRelation.TYPE_SRC and self.leafDirs:
            path = self.expandFiles(directory, self.leafDirs)
        else:
            path = directory

        path = evalEnv(path)
        if sitetype == HDRsyncDirRelation.TYPE_SRC:
            return path
        else:
            return path + "/."

    def getRemotePath(self, site, sitetype):
        path = self.getPath(site, sitetype, True)
        if site.username == None or site.getHostname() == None:
            return path
        else:
            if isinstance(path, list):
                newpath = ""
                for pathstr in path:
                    if newpath != "":
                        newpath = newpath + " "
                    newpath = newpath + pathstr
                path = newpath
            return site.username + "@" + askHostnameIfNeeded(site.getHostname()) + ":'" + path + "'"

    def expandFiles(self, directory, files):
        expanded = []

        for file in files:
            expanded.append(directory + "/" + file)

        return expanded


class HDRsync:

    def __init__(self, name=None, title=None,
                 aHdRsyncDirRelations=None, rsyncCmd=None):
        self.resetVariables()
        self.name = name
        self.title = title
        self.rsyncCmd = rsyncCmd
        self.aHdRsyncDirRelations = aHdRsyncDirRelations
        self.options = []
        self.sites = None

    def getRelations(self):
        return self.aHdRsyncDirRelations

    def setRelations(self, aHdRsyncDirRelations):
        self.aHdRsyncDirRelations = aHdRsyncDirRelations

    def computeRelations(self):
        if self.aHdRsyncDirRelations != None:
            for relation in self.aHdRsyncDirRelations:
                relation.aHDRsyncDirectory = relation.aHDRsyncDirectory + \
                    mountedMedia(relation.mediaDirectory)
                relation.computeSites()

    def setSites(self, sites=None):
        if sites:
            self.sites = sites
        elif not self.sites:

            sites = []
            if self.aHdRsyncDirRelations:
                for relation in self.aHdRsyncDirRelations:
                    sites.extend(relation.getSites())
            else:
                print(
                    "ERROR in HDRsync:getSites():  No HDRsyncDirRelation or HDRsyncDirRelation defined.")
                return None

            try:
                self.sites = set(sites)
            except NameError:
                # Old version of Python (<2.3.x) does not support the "set"
                # function.  Thus we cannot remove duplicates.  Not ideal
                # but it is the best that can be done.
                self.sites = sites

        return self.sites

    def resetVariables(self):
        self.site = None
        self.direction = None
        self.localdir = None
        self.aHdRsyncDirRelations = None

    def setLocalDir(self, localdir):
        self.localdir = localdir

    def set(self, variable, value):
        exec("self." + variable + " = evalEnv(\"" + value + "\")")

    def setRsyncCmd(self, rsyncCmd):
        self.rsyncCmd = rsyncCmd

    def setOptions(self, options):
        self.options = options

#   def resetOptions(self, options):
#     self.rsyncCmd.resetOptions()

    def setTitle(self, title):
        self.title = title

    def run(self, title=None, previousSelection=None):

        self.computeRelations()
        self.setSites()
        self.home = getEnv('HOME')

        if title == None:
            title = self.title

        hdmenuitems = []

        #debug("HDRsyncSoft.options = " + str(self.options), 20)
        if self.options:
            self.rsyncCmd.setOptions(self.options)

        found = False
        if not previousSelection:
            direction = self.rsyncCmd.direction
            if direction:
                for site in self.sites:
                    if site.toKeys == direction:
                        found = True
                        self.direction = "to"
                        self.site = site
                        break
                    elif site.fromKeys == direction:
                        found = True
                        self.direction = "from"
                        self.site = site
                        break

            if not found:
                found = True
                print()
                for site in self.sites:
                    hdmenuitems.append(
                        HDMenuItem("From " + site.name, site.fromKeys, ["from", site]))
                    hdmenuitems.append(
                        HDMenuItem("To " + site.name, site.toKeys,   ["to",   site]))

                if self.site == None:
                    # TODO:  Print graceful error if self.rsyncCmd.key > # of item in
                    #        the menu
                    menu = HDMenu(title, hdmenuitems)
                    self.direction, self.site = menu()
                    debug("self.direction = " + self.direction)
                    debug("self.site      = " + str(self.site))
                else:
                    found = False
                    for site in self.sites:
                        if self.site == site:
                            found = True
                            break
                    if not found:
                        print("Site " + self.site +
                              " not in list of available sites.  Skipping.")
                        return previousSelection
        else:
            self.direction, self.site = previousSelection
            for site in self.sites:
                if site == self.site:
                    found = True
                    break

        print("----------------------------------------------------------------------")
        print(title + " -- " + self.direction + " " + self.site.name + "\n")

        if not found:
            print("Site not supported.  Ignoring request.")
            return previousSelection

        src = None
        dst = None

        for relation in self.aHdRsyncDirRelations:
            self.localsite = None
            for site in self.sites:
                if site.isCurrentSite or \
                   (self.localsite == None and site.name == "local"):
                    hdRsyncDirQ = relation.getHDRsyncDirectoryFromSite(site)
                    debug("Found potential local site =\n" + str(site), 10)
                    path = evalEnv(hdRsyncDirQ.directory)
                    debug("path=" + str(path))
                    if os.path.exists(path):
                        self.localsite = site

            if self.localsite == None:
                print("Error:  Could not locate local site.  Passing.")
                break

            debug("relation = " + str(relation), 10)
            remoteHDRsyncDirectory = relation.getHDRsyncDirectoryFromSite(
                self.site)
            localHDRsyncDirectory = relation.getHDRsyncDirectoryFromSite(
                self.localsite)

            if self.direction == "from":
                dstHDRsyncDirectory = localHDRsyncDirectory
                srcHDRsyncDirectory = remoteHDRsyncDirectory
                dst = relation.getPath(
                    self.localsite, HDRsyncDirRelation.TYPE_DST)
                src = relation.getRemotePath(
                    self.site, HDRsyncDirRelation.TYPE_SRC)
            else:
                srcHDRsyncDirectory = localHDRsyncDirectory
                dstHDRsyncDirectory = remoteHDRsyncDirectory
                src = relation.getPath(
                    self.localsite, HDRsyncDirRelation.TYPE_SRC)
                dst = relation.getRemotePath(
                    self.site, HDRsyncDirRelation.TYPE_DST)

            try:
                #debug("self.localsite =\n" + str(self.localsite), 10)
                #debug("src site =\n" + str(self.src), 10)
                debug("srcHDRsyncDirectory  = " + str(srcHDRsyncDirectory),  5)
                debug("dstHDRsyncDirectory  = " + str(dstHDRsyncDirectory),  5)
                debug("src      = " + str(src),              5)
                debug("dst      = " + str(dst),              5)
            except AttributeError:
                pass

            if os.path.exists(self.home + "/.ssh/id_rsa"):
                sshkey = " -i " + self.home + "/.ssh/id_rsa"
            elif os.path.exists(self.home + "/.ssh/id_dsa"):
                sshkey = " -i " + self.home + "/.ssh/id_dsa"
            elif os.path.exists(self.home + "/.ssh/id_dsa.nopass"):
                sshkey = " -i " + self.home + "/.ssh/id_dsa.nopass"
            else:
                sshkey = None

            statusCode = None
    #     try:
            dstHDRsyncDirectory.executePreCommands(relation)
#       if dstHDRsyncDirectory.precommand != None:
#         dstHD
#         executeCommands(dstHDRsyncDirectory)

            if isinstance(src, str):
                src = [src]
            if isinstance(dst, str):
                dst = [dst]
            (statusCode, output) = self.rsyncCmd.perform(src, dst, None, sshkey,
                                                         remoteHDRsyncDirectory.site.port)

            if statusCode != 0:
                raiseCommandError(statusCode, output, "rsync")

            dstHDRsyncDirectory.executePostCommands(relation)

#     except:
#       print "Error:  Operation aborted.  Status code:  " + str(statusCode)
#       sys.exit(statusCode)

        return [self.direction, self.site]
