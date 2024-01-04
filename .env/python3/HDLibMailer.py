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

# WARNING:
#
#   THIS CLASS SHOULD BE REPLACED WITH THOSE PROVIDED BY PYTHON, I.E. EMAIL.*
#
#
# For email format, see "RFC2822 - Internet Message Format" at:
#
#   http://www.faqs.org/rfcs/rfc2822.html

from HDLib import *
import datetime
import email.Utils


class Email:

    emailbody = None
    header = ""
    message = ""

    def __init__(self):
        self.agent = None
        self.date = None
        self.subject = None

    def addToHeader(self, data, type):
        if data != "" and data != None:
            self.header = self.header + type + ": " + data + "\n"
            return self.header

    def setTo(self, to):
        self.to = to

    def setFrom(self, fromUser):
        self.fromUser = fromUser

    def setSubject(self, subject):
        self.subject = subject

    def setMessage(self, message):
        self.message = message

    def setDate(self, date=email.Utils.formatdate()):
        self.date = date

    def setAgent(self, agent):
        self.agent = agent

    def build(self):
        if not self.date:
            self.setDate()

        self.addToHeader(self.date,     "Date")
        self.addToHeader(self.fromUser, "From")
        self.addToHeader(self.to,       "To")
        self.addToHeader(self.subject,  "Subject")

        self.emailbody = self.header + self.message

    def send(self):
        if not self.emailbody:
            self.build()

        if not self.agent:
            self.agent = "sendmail -oi -t"

        return execute(self.agent, stdinText=self.emailbody)
