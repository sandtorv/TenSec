//
//  GameHelper.swift
//  TenSec
//
//  Created by Sebastian Sandtorv  on 19/05/15.
//  Copyright (c) 2015 Sebastian Sandtorv. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

// What game type
var gameType:Int = 0
// Initialize var/int/etc for game handling
var gameActive:Int = 0
var gameOver:Int = 0
var oldGameScore:Int = 0
// Score
var scoreCount:Int = 0

// Generates a random color
func newRandomColor() -> UIColor{
    var red:CGFloat = CGFloat(drand48())
    var green:CGFloat = CGFloat(drand48())
    var blue:CGFloat = CGFloat(drand48())
    return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
}

// Generates a random number
func randomNumber() -> CGFloat{
    var number:CGFloat = CGFloat(drand48()*150)
    return number
}

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file as String, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}