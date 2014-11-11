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
        return self.blueCD == 3 ?  3 : (self.blueCD++) ;
    }
    
    func increaseRedCD() -> Int
    {
        return self.redCD == 3 ?  3 : (self.redCD++) ;
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