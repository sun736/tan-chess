//
//  SkillController.swift
//  WildPiece
//
//  Created by Liu Yixiang on 11/10/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import Foundation
import SpriteKit

class SkillController
{
    private var blueCD : Int = 0
    private var redCD : Int = 0
    
    init()
    {
        self.blueCD = 0;
        self.redCD = 0;
    }
    
    func increaseBlueCD() -> Int
    {
        return self.blueCD == 2 ?  2 : (self.blueCD++) ;
    }
    
    func increaseRedCD() -> Int
    {
        return self.redCD == 2 ?  2 : (self.redCD++) ;
    }
    
    func getCD(player: Player)->Int
    {
        if player.id == 1
        {
            return self.blueCD
        }else
        {
            return self.redCD
        }
    }
    
    func setCD(player: Player, cd: Int)
    {
        if player.id == 1
        {
            self.blueCD = cd;
        }
        else
        {
            self.redCD = cd;
        }
    }
    
    func cleanCD(player: Player)
    {
        if player.id == 1
        {
            self.blueCD = 0
        }else
        {
            self.redCD = 0
        }
    }
    
    func getBlueCD() -> Int
    {
        return self.blueCD
    }
    
    func getRedCD() -> Int
    {
        return self.redCD
    }
    
    func clearBlueCD()
    {
        self.blueCD = 0;
    }
    
    func clearRedCD()
    {
        self.redCD = 0;
    }
}