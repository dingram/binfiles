#!/usr/bin/env python

# $Id: nfbfile.py,v 1.4 2004/09/28 09:59:31 john Exp $
#
# JW.

import struct, sys, os, zlib, time, warnings, types, string

__all__ = [ 'NfbInfo', 'NfbFile' ]

ftypetbl = {
   1: 'FILE',
   2: 'DIRECTORY',
}

class ucs2string:
   """Strings in Nokia files are a two byte per character encoding,
   probably UCS-2."""

   def __init__(self, data):
      self.__data = data

   def __len__(self):
      return len(self.__data) / 2

   def __str__(self):
      return self.convert()

   def __eq__(self, value):
      return value == str(self).encode('utf-8')

   def convert(self):
      """Parse the data into a unicode type string."""
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


class IndexEntry:
   """FolderIndex or InfoIndex entry."""

   def __init__(self, line):
      data = line.split('\n')
      self.name = data[0]
      del(data[0])
      self.values = {}
      while len(data) >= 3:
         num = int(data[0])
         typ = data[1]
         val = data[2]
         if typ == 'long':
            val = long(val)
         elif typ == 'string':
            pass
         else:
            warnings.warn("Unknown Index value type `%s'" % typ)
         self.values[num] = val
         del(data[:3])

   def __repr__(self):
      s = '<IndexEntry: %s {' % self.name
      for k,v in self.values.iteritems():
         s += ' %s: %s'  % (k,v)
      return s + ' }>'

   def __getitem__(self, key):
      return self.values[key]


class IndexFile:
   """FolderIndex and InfoIndex file reading."""

   def __init__(self, data):
      assert(data[:4] == '2\r\n\n')
      self.version = int(data[:data.find('\r\n')])
      data = str(ucs2string(data[5:-2])).encode('utf-8').split('\n\n')
      self.rows = []
      for row in data:
         self.rows.append(IndexEntry(row))

   def __len__(self):
      return len(self.rows)

   def __getitem__(self, index):
      return self.rows[index]

   def __iter__(self):
      return iter(self.rows)


class InfoIndex(IndexFile):
   def __getitem__(self, key):
      index = -1
      if type(key) == types.StringType:
         if key[:7] == '\\FILES\\' and key[7] in string.digits:
            index = int(key[7:])
      elif type(key) == types.IntType:
         index = key
      return self.rows[index]


def readstring(fp, length=-1):
   """Read a UCS-2 string from the file fp."""
   if length == -1:
      length, = struct.unpack('L', fp.read(4))
   return ucs2string(fp.read(length * 2))

class NfbInfo:
   def __init__(self):
      self.filetype = ''
      self.filename = ''
      self.filesize = 0
      self.date_time = 0

   def __repr__(self):
      s = '<NfbInfo: %s; %s' % (self.filetype, self.filename)
      if self.filetype == 'FILE':
         s += '; %d' % self.filesize
         s += '; %s' % \
            time.strftime('%Y-%m-%d.%H:%M:%S', time.localtime(self.date_time))
      return s + '>'
      

class NfbFile:
   HiddenFiles = (
         '\\FILES',
         '\\FILES\\FolderIndex',
         '\\FILES\\InfoIndex',
         '\\FILES\\Language'
         )

   def __init__(self, filename, mode='r'):
      assert(mode == 'r')
      self.filename = filename
      self.mode = mode
      self.size = os.path.getsize(self.filename)
      self.fp = open(self.filename, self.mode)
      self.version, = struct.unpack('L', self.fp.read(4))
      assert(self.version == 3)
      self.fp.seek(0)
      length = self.size - 4
      crcvalue = 0
      bytes = 64*1024
      while length > 0:
         if bytes > length:
            bytes = length
         buf = self.fp.read(bytes)
         length -= len(buf)
         crcvalue = zlib.crc32(buf, crcvalue)
      self.crcvalue, = struct.unpack('l', self.fp.read(4))
      if long(crcvalue) != self.crcvalue:
         warnings.warn("CRC mismatch")
      self.fp.seek(4)
      self.firmware = readstring(self.fp)
      self.model = readstring(self.fp)
      self.entries, = struct.unpack('L', self.fp.read(4))
      self._startpos = self.fp.tell()
      self.folderindex = self.read('\\FILES\\FolderIndex')
      if self.folderindex:
         self.folderindex = IndexFile(self.folderindex)
      self.infoindex = self.read('\\FILES\\InfoIndex')
      if self.infoindex:
         self.infoindex = InfoIndex(self.infoindex)
      self.language = self.read('\\FILES\\Language')
      if self.language:
         self.language = str(ucs2string(self.language)).encode('utf-8')

   def _traverse(self, fn, user):
      self.fp.seek(self._startpos)
      for entry in xrange(self.entries):
         ftype, = struct.unpack('L', self.fp.read(4))
         path = str(readstring(self.fp)).encode('utf-8')
         
         if hasattr(self, 'infoindex') and self.infoindex \
               and path[:7] == '\\FILES\\' \
               and len(path) > 6 and path[7] in string.digits:
            info = self.infoindex[path]
            path = '\\FILES\\' + info.name
         else:
            info = None
         if ftype == 1:
            length, = struct.unpack('L', self.fp.read(4))
            offset = self.fp.tell()
            self.fp.seek(length, 1)
            timestamp, = struct.unpack('L', self.fp.read(4))
            if info:
               timestamp = info[0]
            fn(user, ftype, path, length, timestamp, offset)
         elif ftype == 2:
            fn(user, ftype, path)

   def _namelist(self, names, ftype, path, length=0, timestamp=0, offset=0):
      if path not in NfbFile.HiddenFiles:
         names.append(path)

   def namelist(self):
      names = []
      self._traverse(self._namelist, names)
      return names

   def _infolist(self, infos, ftype, path, length=0, timestamp=0, offset=0):
      if path not in NfbFile.HiddenFiles:
         info = NfbInfo()
         info.filetype = ftypetbl[ftype]
         info.filename = path
         if ftype == 1:
            info.filesize = length
            info.date_time = timestamp
         infos.append(info)

   def infolist(self):
      infos = []
      self._traverse(self._infolist, infos)
      return infos

   def _read(self, user, ftype, path, length=0, timestamp=0, offset=0):
      if user['name'] == path:
         user['ftype'] = ftype
         user['offset'] = offset
         user['length'] = length

   def _getinfo(self, user, ftype, path, length=0, timestamp=0, offset=0):
      if user['name'] == path:
         user['info'] = ( ftype, path, length, timestamp, offset )

   def getinfo(self, name):
      user = { 'name': name, 'info': None }
      self._traverse(self._getinfo, user)
      if user['info']:
         info = NfbInfo()
         ftype, path, length, timestamp, offset = user['info']
         info.filetype = ftypetbl[ftype]
         info.filename = path
         info.filesize = length
         info.date_time = timestamp
         return info
      return None

   def read(self, name):
      user = { 'name': name, 'offset': 0, 'ftype': 0, 'length': 0 }
      self._traverse(self._read, user)
      if user['offset'] == 0 or user['ftype'] != 1:
         return ''
      self.fp.seek(user['offset'])
      return self.fp.read(user['length'])

def usage(status):
   print >> sys.stderr, "Usage: NfbFile.py [-t|-x] [-v] NFB-FILE"
   sys.exit(status)

if __name__ == '__main__':
   import getopt
   
   opts, args = getopt.getopt(sys.argv[1:], 'txv?')

   mode = 'test'
   verbose = 0
   for opt,arg in opts:
      if opt == '-t':
         mode = 'test'
      elif opt == '-x':
         mode = 'extract'
      elif opt == '-v':
         verbose += 1
      elif opt == '-?':
         usage(0)

   if len(args) == 0:
      usage(1)

   filename = args[0]
   del(args[0])
   nfbfile = NfbFile(filename)
   if mode == 'test':
      print "Phone Firmware:", nfbfile.firmware
      print "Phone Model:", nfbfile.model
      if nfbfile.language:
         print "User file language:", nfbfile.language
      if verbose == 1:
         for name in nfbfile.namelist():
            print name
      elif verbose > 1:
         for info in nfbfile.infolist():
            print info
   elif mode == 'extract':
      if args:
         for arcname in args:
            arcname = arcname.replace('/', '\\')
            info = nfbfile.getinfo(arcname)
            if info:
               if os.isatty(sys.stdout.fileno()):
                  print info
                  print "(Direct stdout to a file to save content.)"
               else:
                  data = nfbfile.read(arcname)
                  sys.stdout.write(data)
            else:
               print "Not found", arcname
