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

import string
import os
import re


def findExistingPath(listOfPaths):
    for path in listOfPaths:
        if os.path.exists(path):
            return path
    return None


def checkOwnershipAndPermissions(path, userid, groupid, permissions):

    # st_mode (protection bits), st_ino (inode number), st_dev (device),
    # st_nlink (number of hard links), st_uid (user ID of owner), st_gid
    # (group ID of owner), st_size (size of file, in bytes), st_atime
    # (time of most recent access), st_mtime (time of most recent content
    # modification), st_ctime (platform dependent; time of most recent
    # metadata change on Unix, or the time of creation on Windows).

    st_mode, st_ino, st_dev, st_nlink, st_uid, st_gid, st_size, \
        st_atime, st_mtime, st_ctime = os.lstat(path)

    if userid != None and st_uid != userid:
        return False

    if groupid != None and st_gid != groupid:
        return False

    if permissions != None and ((st_mode & 0o777) & permissions != permissions):
        return False

    return True

#   return ( st_uid == userid  ) and \
#          ( st_gid == groupid ) and \
#          ( (st_mode & 0777) & permissions == permissions )


# chmod is octal, like 0660.
def fprint(filename, string, chmod=None):
    handle = open(filename, 'w')
    if chmod != None:
        os.chmod(filename, chmod)
    print(string, file=handle)
    handle.close()


def cleanEndOfPath(path):
    """Remove '/' or '/.' from the end of the path given."""

    if path[-2:] == "/.":
        return path[:-2]
    elif path[-1:] == "/":
        return path[:-1]
    else:
        return path


def findMatchingPath(arg1, arg2, separator="/"):
    cleanEndOfPath(arg1)
    cleanEndOfPath(arg2)

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
    while True:
        index = str.rfind(longest, separator, start) + 1
        #print("Comparing " + longest[0:index] + " with " +  shortest[0:index] + \
        #       "  - start == " + str(start) + "  - index == " + str(index))
        if longest[0:index-1] != shortest[0:index-1]:
            break
        else:
            matchindex = index - 1
            start = index

    # print "Returning " + longest[0:matchindex]
    return longest[0:matchindex], \
        cleanEndOfPath(arg1[matchindex:]), \
        cleanEndOfPath(arg2[matchindex:])


def shortestRelativePath(cwd, srcdir, separator="/"):
    commondir, cwdextra, srcdirextra = \
        findMatchingPath(cwd, srcdir)

    # Removing leading separator (usually '/') from srcdirextra.  This
    # avoids returning a result that looks like ..//rst/xyz, i.e. with
    # double separators.
    if srcdirextra[0] == separator:
        srcdirextra = srcdirextra[1:]

    cwdcount = cwdextra.count(separator)
    parentdir = ""

    for index in range(0, cwdcount):
        parentdir += ".." + separator

    return parentdir + srcdirextra
