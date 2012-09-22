#! /usr/bin/python
# -*- coding: utf-8 -*-
"""
Created on Fri Sep 21 18:37:17 2012

@author: lusaisai

This program will randomly choose and play a video file.
"""
import os
import random
import re
import subprocess

class randomVideoPlay(object):
    def __init__(self, directory, player):
        self.videoDir = directory
        self.videoPlayer = player
        self.videoSfx = [ 'avi', 'mp4', 'rm', 'rmvb', 'wmv', 'iso', 'mkv', 'mpg', 'mpeg', 'vob', 'mov' ]
        self.pattern = '.*(' + '|'.join(self.videoSfx) + ')$'
    
    # Find the file randomly    
    def find(self, topDir):
        print "Change directory into %s" % topDir
        os.chdir(topDir)
        allFiles = os.listdir(topDir)
        retryTimes = len(allFiles)/2 + 1
        for i in range(retryTimes):
            videoFile = random.choice(allFiles)
            if re.match(self.pattern, videoFile, re.IGNORECASE ):
                return videoFile
            elif os.path.isdir(videoFile):
                return self.find(os.path.join(topDir, videoFile))
            else:
                pass
        return self.find(self.videoDir)
                
    # Play the File
    def play(self, videoFile):
        command = [ self.videoPlayer, videoFile ]
        #blackHole = open('/dev/null')
        print "Now playing %s ..." % videoFile
        #subprocess.Popen( command, stdout = blackHole, stderr = blackHole )
        subprocess.Popen( command )
        

videoDir = '/home/lusaisai/Videos'
player = 'vlc'
myPlay = randomVideoPlay(videoDir,player)
myPlay.play(myPlay.find(myPlay.videoDir))
