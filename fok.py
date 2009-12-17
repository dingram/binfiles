#!/usr/bin/python
from __future__ import division
from random import normalvariate, shuffle, choice, random

capacity = 650 # size of the disc

## BEGIN: added ##############################
class File(object):
	def __init__(self,name,sz):
		self.filename=name
		self.size=sz
	def getname(self):
		return self.filename
	def getsize(self):
		return self.size
##  END: added  ##############################

# generate file sizes pretty much at random, lacking real data
files = [File(i,min(abs(normalvariate(200, 200)), capacity)) for i in range(500)]
#print min(files), max(files), sum(files), sum(files)/len(files)
totsize=0
for f in files:
	totsize += f.getsize()

siblings = 100 # combinations per generation (>=2)
generations = 100 # generations (>=1)
breeders = 1 # how many of each generation should breed to the next one; 
             # only 1 is supported
groups = []

class Disc(object):
    def __init__(self):
        self.files = []
        self.totalsize = 0
        self.fill = 0
    def addfile(self, file):
        if self.totalsize + file.getsize <= capacity:
            self.files.append(file)
            self.totalsize += file.getsize
            self.fill = self.totalsize / capacity
            return True
        else:
            return False # can't add

def discfillcomp(a, b): # compares disc fill rates
    return cmp(a.fill, b.fill)

def score(fileslist):
    discsize = 0
    i = 0
    discs = []
    disc = Disc()
    for fs in fileslist:
        if not disc.addfile(fs): # doesn't fit on same -> close and start new
            discs.append(disc)
            disc = Disc()
            disc.addfile(fs)
    discs.append(disc) # append last disc
    score = 0
    #discs.sort(discfillcomp)
    for disc in discs[1:]: # don't count the least filled disc, 
                           # because that one may be almost-empty by chance
        score += disc.fill # percentage filled -> higher score = better fill
    return score/len(discs), discs

def cmpgroups(a, b): # compare groups by their score, in descending order
    return -cmp(a[0], b[0])

def printgroups(gennr, groups, printfiles=False):
    print "Generation %s breeders:" % gennr
    for group in groups[:breeders]: # print all breeders in this generation
        print "  Score = %2.5f (%d discs)" % (group[0], len(group[1]))
        for disc in group[1]:
            if printfiles:
                print "      %2.5f" % disc.fill, \
                      ['%2.2f' % fs for fs in disc.files]

def createfirstgeneration():
    # create initial generation
    for j in range(siblings):
        shuffle(files)
        groups.append(score(files))
    c = 0
    for disc in groups[0][1]:
        c += len(disc.files)
    print len(files), c
    groups.sort(cmpgroups)
    printgroups(0, groups)

def makechild(parentdiscs):
    # takes a list of disc objects and generates a new generation
    # by shuffling the discs around as well as the files inside the discs
    if random() > 0.5: # 50/50 chance of shuffling the discs
        shuffle(parentdiscs)
    child = []
    for disc in parentdiscs:
        fs = disc.files[:]
        if random() > 0.5: # 50/50 chance of shuffling the 
                           # order of the files
            shuffle(fs)
        child.extend(fs)
    return child
    
createfirstgeneration()
for gen in range(generations):
    parent = groups[0] # tuple of score and list of discs
    groups = []
    newgen = makechild(parent[1][:])
    if len(newgen) <> len(files):
        print "ERROR"
    groups.append(score(newgen))
    groups.sort(cmpgroups)
    printgroups(gen+1, groups)
    
printgroups('final', groups, True)
