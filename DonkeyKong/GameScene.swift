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
        let platformWidth = 800
        let platformHeight = 25
        addChild(createRectangleObject(w: platformWidth, h: platformHeight, x: size.width / 3, y: size.height / 6, color: SKColor.red, rotation: -CGFloat.pi / 64))
        addChild(createRectangleObject(w: platformWidth, h: platformHeight, x: size.width * 2 / 3, y: size.height * 2 / 6, color: SKColor.red,rotation: CGFloat.pi / 64))
        addChild(createRectangleObject(w: platformWidth, h: platformHeight, x: size.width / 3, y: size.height * 3 / 6, color: SKColor.red,rotation: -CGFloat.pi / 64))
        addChild(createRectangleObject(w: platformWidth, h: platformHeight, x: size.width * 2 / 3, y: size.height * 4 / 6, color: SKColor.red,rotation: CGFloat.pi / 64))
        addChild(createRectangleObject(w: platformWidth, h: platformHeight, x: size.width / 3, y: size.height * 5 / 6, color: SKColor.red, rotation: -CGFloat.pi / 64))
        
        // creates the ladders
        let ladderWidth = 50
        let ladderHeight = 200
        addChild(createRectangleObject(w: ladderWidth, h: ladderHeight, x: size.width / 3, y: size.height / 6 + CGFloat(ladderHeight) / 2,color: SKColor.cyan, rotation: -CGFloat.pi / 64))
        addChild(createRectangleObject(w: ladderWidth, h: ladderHeight, x: size.width * 2 / 3, y: size.height * 2 / 6 + CGFloat(ladderHeight) / 2,color: SKColor.cyan, rotation: CGFloat.pi / 64))
        addChild(createRectangleObject(w: ladderWidth, h: ladderHeight, x: size.width / 3, y: size.height * 3 / 6 + CGFloat(ladderHeight) / 2,color: SKColor.cyan, rotation: -CGFloat.pi / 64))
        addChild(createRectangleObject(w: ladderWidth, h: ladderHeight, x: size.width * 2 / 3, y: size.height * 4 / 6 + CGFloat(ladderHeight) / 2,color: SKColor.cyan, rotation: CGFloat.pi / 64))
        addChild(createRectangleObject(w: ladderWidth, h: ladderHeight, x: size.width / 3, y: size.height * 5 / 6 + CGFloat(ladderHeight) / 2,color: SKColor.cyan, rotation: -CGFloat.pi / 64))

        
        addChild(createBarrels(radius: 30))
            
    }
    
    func createBarrels(radius : CGFloat) -> SKShapeNode {
        let barrel = SKShapeNode(circleOfRadius: radius)
        
        barrel.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        barrel.fillColor = SKColor.orange
        barrel.position = CGPoint(x: size.width / 2, y: size.height * 9 / 10)
        
        return barrel
    }
    
    func createRectangleObject(w: Int, h: Int, x: CGFloat, y: CGFloat, color: SKColor, rotation: CGFloat) -> SKShapeNode {
        let rect = SKShapeNode(rectOf: CGSize(width: w, height: h))
        
        rect.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: w, height: h))
        rect.fillColor = color
        rect.position = CGPoint(x: x, y: y)
        rect.zRotation = rotation
        rect.physicsBody?.affectedByGravity = false
        rect.physicsBody?.isDynamic = false
        //rect.physicsBody?.pinned = true
        
        return rect
    }

}
