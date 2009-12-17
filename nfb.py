#!/usr/bin/env python

from __future__ import generators

import struct, sys, os, time, types, glob, posixfile, zlib

ftypetbl = {
   1: 'FILE',
   2: 'DIRECTORY',
}

class ucs2string:
   def __init__(self, data):
      self.__data = data

   def __len__(self):
      return len(self.__data) / 2

   def __str__(self):
      return self.convert()

   def convert(self):
      s = self.__data
      u = u''
      while s:
         c = s[:2]
         s = s[2:]
         c = ord(c[0]) | (ord(c[1])<<8)
         u += unichr(c)
      return u

   def write(self, fp):
      return fp.write(self.__data)

def readstring(fp, length=-1):
   if length == -1:
      length, = struct.unpack('L', fp.read(4))
   return ucs2string(fp.read(length * 2))

def rip(filename):
   print "Attempting to rip", filename
   fp = open(filename)
   fp.seek(-4, posixfile.SEEK_END)
   length = fp.tell()
   fp.seek(0)
   crc = zlib.crc32(fp.read(length))
   fp.seek(0)
   version, = struct.unpack('L', fp.read(4))
   id = readstring(fp)
   phone = readstring(fp)

   print "Version:", version
   print "Ident:", id
   print "Phone:", phone
   
   enterroot(fp)

   checksum, = struct.unpack('l', fp.read(4))
   print "Checksum:", hex(checksum),
   if checksum == crc:
      print "VALID"
   else:
      print "INVALID"

def enterroot(fp):
   nelem, = struct.unpack('L', fp.read(4))
   print "Directory entries:", nelem
   for fnum in range(nelem):
      ftype, = struct.unpack('L', fp.read(4))
      path = readstring(fp)
      print "%-10s%-20s" % (ftypetbl[ftype], path),
      if ftype == 1:
         length, = struct.unpack('L', fp.read(4))
         data = fp.read(length)
         stamp, = struct.unpack('L', fp.read(4))
         print time.ctime(stamp), "%6d bytes" % len(data)
      elif ftype == 2:
         print
         data = ''
      if str(path) in extract:
         print "Extracting"
         w = os.popen("less", "w")
         w.write(data)
         w.close()

extract = sys.argv
del(extract[0])
for nfb in glob.glob('*.nf[bc]'):
   rip(nfb)

