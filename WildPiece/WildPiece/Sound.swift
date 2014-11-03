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
    var collisionEffect = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("collision", ofType: "wav")!)

    var audioPlayer = AVAudioPlayer()
    var effectPlayer = AVAudioPlayer()
    var musicOn : Bool?
   // var audioOn : Bool?
    
    init()
    {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        if (userDefaults.valueForKey("musicOn") != nil) {
            self.musicOn = userDefaults.valueForKey("musicOn")?.boolValue
        }
        else {
            userDefaults.setValue(true, forKey: "musicOn")
            self.musicOn = true
        }

    }

    
    func playBackgroundMusic()
    {
        if self.musicOn == true{
            self.audioPlayer = AVAudioPlayer(contentsOfURL: backgroundMusic, error: nil)
            if self.audioPlayer.prepareToPlay() {
                println("begin play music")
                self.audioPlayer.play();
            }
        }
    }
    
    func stopBackgroundMusic()
    {
        if self.musicOn == true{
            if self.audioPlayer.playing{
                println("stop play music")
                self.audioPlayer.stop();
            }
        }
    }
    
    func playEffect()
    {
        self.effectPlayer = AVAudioPlayer(contentsOfURL: collisionEffect, error: nil)
        if self.effectPlayer.prepareToPlay() {
            //println("begin play music")
            self.effectPlayer.play();
        }

    }
}