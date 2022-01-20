//
//  GameScene.swift
//  DonkeyKong
//
//  Created by soham gupta on 1/18/22.
//

import Foundation
import SpriteKit
import GameKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    
    override func didMove(to view: SKView) {
        anchorPoint = .zero
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        
        // creates the platforms

        addChild(createPlatform(x: size.width / 3, y: size.height / 6, rotation: -CGFloat.pi / 48))
        addChild(createPlatform(x: size.width * 2 / 3, y: size.height * 2 / 6, rotation: CGFloat.pi / 48))
        addChild(createPlatform(x: size.width / 3, y: size.height * 3 / 6, rotation: -CGFloat.pi / 48))
        addChild(createPlatform(x: size.width * 2 / 3, y: size.height * 4 / 6, rotation: CGFloat.pi / 48))
        addChild(createPlatform(x: size.width / 3, y: size.height * 5 / 6, rotation: -CGFloat.pi / 48))
        
        // creates the ladders
        let ladderHeight = 200
        addChild(createLadder(x: size.width / 3, y: size.height / 6 + CGFloat(ladderHeight) / 2, rotation: -CGFloat.pi / 48))
        addChild(createLadder(x: size.width * 2 / 3, y: size.height * 2 / 6 + CGFloat(ladderHeight) / 2, rotation: CGFloat.pi / 48))
        addChild(createLadder(x: size.width / 3, y: size.height * 3 / 6 + CGFloat(ladderHeight) / 2, rotation: -CGFloat.pi / 48))
        addChild(createLadder(x: size.width * 2 / 3, y: size.height * 4 / 6 + CGFloat(ladderHeight) / 2, rotation: CGFloat.pi / 48))
        addChild(createLadder (x: size.width / 3, y: size.height * 5 / 6 + CGFloat(ladderHeight) / 2, rotation: -CGFloat.pi / 48))

        
        addChild(createBarrels(radius: 30))
            
    }
    
    func createBarrels(radius : CGFloat) -> SKShapeNode {
        let barrel = SKShapeNode(circleOfRadius: radius)
        
        barrel.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        barrel.fillColor = SKColor.orange
        barrel.position = CGPoint(x: size.width / 2, y: size.height * 9 / 10)
        barrel.physicsBody?.categoryBitMask = 1
        barrel.physicsBody?.contactTestBitMask = 0
        barrel.physicsBody?.friction = 0.7
        
        return barrel
    }
    
    func createPlatform(x: CGFloat, y: CGFloat,rotation: CGFloat) -> SKShapeNode {
        let rect = SKShapeNode(rectOf: CGSize(width: 650, height: 25))
        
        rect.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 650, height: 25))
        rect.fillColor = SKColor.red
        rect.position = CGPoint(x: x, y: y)
        rect.zRotation = rotation
        rect.physicsBody?.affectedByGravity = false
        rect.physicsBody?.isDynamic = false
        rect.physicsBody?.contactTestBitMask = 1
        rect.physicsBody?.collisionBitMask = 0
        
        //rect.physicsBody?.pinned = true
        
        return rect
    }
    
    func createLadder(x: CGFloat, y: CGFloat, rotation: CGFloat) -> SKShapeNode {
        let rect = SKShapeNode(rectOf: CGSize(width: 50, height: 200))
        
        rect.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 200))
        rect.fillColor = SKColor.cyan
        rect.position = CGPoint(x: x, y: y)
        rect.zRotation = rotation
        rect.physicsBody?.affectedByGravity = false
        rect.physicsBody?.isDynamic = false
        rect.physicsBody?.categoryBitMask = 0
        rect.physicsBody?.collisionBitMask = 1
        
        //rect.physicsBody?.pinned = true
        
        return rect
    }
    

}
