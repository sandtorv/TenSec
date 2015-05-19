//
//  GameScene.swift
//  TenSec
//
//  Created by Sebastian Sandtorv on 09/12/14.
//  Copyright (c) 2014 Sebastian Sandtorv. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    override func didMoveToView(view: SKView) {
        self.physicsWorld.gravity.dy = -9.8

    }
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            if(gameActive == 1 && gameOver == 0){
                let location = touch.locationInNode(self)
                
                let sprite = SKLabelNode (fontNamed: "GillSans")
                sprite.fontSize = randomNumber()
                sprite.fontColor = newRandomColor()
                sprite.position = location
                sprite.text = String(scoreCount + 1)
                sprite.physicsBody = SKPhysicsBody(circleOfRadius: sprite.fontSize/1.33)
                sprite.physicsBody?.dynamic = true
                let scale = SKAction.scaleBy(4, duration: 2)
                let fade  = SKAction.fadeAlphaBy(0, duration: 1)
                
                
                let sequence = SKAction.sequence([scale, fade]);
                
                sprite.runAction(sequence);
                self.addChild(sprite)
                scoreCount++
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
    }
}
