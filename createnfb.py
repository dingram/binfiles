#!/usr/bin/env python

from __future__ import generators

import struct, sys, os, time, types, glob, posixfile, zlib, cStringIO

def writestring(s):
   s = unicode(s, 'latin1').encode('utf16')[2:]
   return struct.pack('L', len(s)/2) + s

fp = cStringIO.StringIO()
fp.write(struct.pack('L', 3))          # Version
fp.write(writestring("RH-12"))         # Firmware
fp.write(writestring("Nokia 6230"))    # Phone
fp.write(struct.pack('L', 1))          # NEntries

data = open("Calendar.ncc").read()

fp.write(struct.pack('L', 1))          # FType: File
fp.write(writestring(r"\CALENDAR"))    # Filename
fp.write(struct.pack('L', len(data)))  # Length
fp.write(data)                         # Data
fp.write(struct.pack('L', time.time()))# Timestamp

data = fp.getvalue()

fp = open('output.nfb', 'w')
fp.write(data)
fp.write(struct.pack('L', zlib.crc32(data))) # Checksum
fp.close()
