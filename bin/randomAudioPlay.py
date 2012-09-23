#! /usr/bin/python
# -*- coding: utf-8 -*-
"""
Created on Sat Sep 22 13:53:09 2012

@author: lusaisai

This program will randomly pick songs to play, numbers of songs and search pattern can be provided.
In the backend, a sqlite db is needed, in which there's table called music with only one column full_path.
The sqlite db can be created use script musicDBUpd.sh.
"""

import sqlite3
import subprocess
import sys
import os

class randomAudioPlay(object):
    def __init__(self, dbFile, player):
        self.dbFile = dbFile
        self.audioPlayer = player
        
    def usage(self):
        print "Randomly choose 15 songs by default."
        print "You can also use it like, %s [number of songs] [search pattern]..." % os.path.basename(args[0])
        print "For example, %s 30 '品冠'" % os.path.basename(args[0])
        print "For example, %s 30" % os.path.basename(args[0])
        print "For example, %s '品冠'" % os.path.basename(args[0])
        print "For example, %s 30 '品冠' '梁静茹'" % os.path.basename(args[0])
        print "For example, %s '品冠' '梁静茹'" % os.path.basename(args[0])
        
    def setQuery(self, songNum, searchPattern):
        queryHead = 'select * from music '
        queryFoot = ' order by random() limit %s;' % songNum
        try:
            if len(searchPattern) >= 2:
                searchPattern.remove('')
        except ValueError:
            pass
        patterns = list(enumerate(searchPattern))
        for pattern in patterns:
            if pattern[0] == 0:
                query = queryHead + " where full_path like '%%%s%%' " % pattern[1]
            else:
                query = query + " or full_path like '%%%s%%' " % pattern[1]
        query = query + queryFoot
        return query
        
        
    def getSongs(self, songNum, songPattern):
        # for ease of use, if the first argument is not an integer, treat it like pattern
        if songNum.isdigit():
            pass
        else:
            songPattern.append(songNum)
            songNum = 15
        
        con = sqlite3.connect(self.dbFile)
        cur = con.cursor()
        cur.execute(self.setQuery(songNum, songPattern))
        songs = [cols[0] for cols in cur.fetchall()]
        cur.close()
        return songs
        
    def play(self,songs):
        blackHole = open('/dev/null')
        command = songs[:]
        command.insert(0, self.audioPlayer)
        subprocess.Popen( command, stdout=blackHole, stderr=blackHole )
        
dbFile = "/home/lusaisai/MyPCTools/files/allMusic.db"
player = "audacious"
myPlay = randomAudioPlay(dbFile,player)
songNum = '15'
songPattern = ['']
args = sys.argv
argsNum = len(args)

if argsNum == 1:
    myPlay.usage()

if argsNum >= 2:
    songNum = args[1]

if argsNum >= 3:
    songPattern = args[2:] 

myPlay.play(myPlay.getSongs(songNum, songPattern ))
