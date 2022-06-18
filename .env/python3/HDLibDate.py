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

from HDLib import *
import datetime

NORMAL = 0
SHORT = 1

# ----------------------------------------------------------------------


def parseIn(keyword, string):
    deltaRE = re.compile("(in\s+)?(?<!at ).*?(\d+)\s+" + keyword + "?.*")
    deltaMO = deltaRE.search(string)
    if deltaMO != None:
        #hdlibDebug("deltaMO.groups() = " + str(deltaMO.groups()))
        return int(deltaMO.group(2))
    else:
        return 0


# ----------------------------------------------------------------------
def parse(string):
    global hdlibDebug
    hdlibDebug("------------------------------")
    hdlibDebug.function(string)

    absMO = re.compile("at\s+(\d+)(:(\d+)){0,1}").search(string)
    absoluteTime = False
    if absMO != None:
        hdlibDebug("absMO.groups() = " + str(absMO.groups()))
        abshour = absMO.group(1)
        absminute = absMO.group(3)
        if abshour:
            abshour = int(abshour)
            absoluteTime = True
        else:
            abshour = 0
        if absminute:
            absminute = int(absminute)
            absoluteTime = True
        else:
            absminute = 0

    daysRel = parseIn("days",    string)
    hoursRel = parseIn("hours",   string)
    minutesRel = parseIn("minutes", string)

    # First, we apply the delta, then the absolute time.
    nowdt = datetime.datetime.now()
    deltatd = datetime.timedelta(
        days=daysRel, hours=hoursRel, minutes=minutesRel)
    newdt = nowdt+deltatd

    if absoluteTime:
        newdt = datetime.datetime(newdt.year, newdt.month, newdt.day,
                                  abshour, absminute)

    hdlibDebug("deltatd = " + str(deltatd))
    hdlibDebug("nowdt   = " + str(nowdt))
    hdlibDebug("newdt   = " + str(newdt))
    return newdt


# ----------------------------------------------------------------------
def timeToString(timeunits, timestring):
    if timeunits > 1:
        return str(timeunits)+" " + timestring + "s"
    elif timeunits == 1:
        return "1 " + timestring
    else:
        return None


# ----------------------------------------------------------------------
def concatenateStrings(string, timestr):
    if timestr:
        if string != "":
            string = timestr + ", " + string
        else:
            string = timestr
    return string


# ----------------------------------------------------------------------
def convertSecondsToTimeString(totalseconds, format=NORMAL):
    """Converts seconds to a human readable form expressed in days, hours, minutes and seconds.

    seconds must be an integer.
    """
    DAY = 86400
    HOUR = 3600
    MINUTE = 60

    days = totalseconds/DAY
    remaining = totalseconds % DAY
    hours = remaining/HOUR
    remaining = totalseconds % HOUR
    minutes = remaining/MINUTE
    seconds = remaining % MINUTE

    daystr = timeToString(days, "day")
    hourstr = timeToString(hours, "hour")
    minutestr = timeToString(minutes, "minute")
    secondstr = timeToString(seconds, "second")

    string = ""
    string = concatenateStrings(string, secondstr)
    string = concatenateStrings(string, minutestr)
    string = concatenateStrings(string, hourstr)
    string = concatenateStrings(string, daystr)

    return string
