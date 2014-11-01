//
//  Sound.swift
//  WildPiece
//
//  Created by Liu Yixiang on 11/1/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation

class Sound {
    var backgroundMusic = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("backgroundMusic", ofType: "mp3")!)
    var audioPlayer = AVAudioPlayer()
   
    
    func playBackgroundMusic()
    {
        self.audioPlayer = AVAudioPlayer(contentsOfURL: backgroundMusic, error: nil)
        if self.audioPlayer.prepareToPlay() {
            println("begin play music")
            self.audioPlayer.play();
        }
    }
    
    func stopBackgroundMusic()
    {
        
        if self.audioPlayer.playing{
            println("stop play music")
            self.audioPlayer.stop();
        }
    }
}