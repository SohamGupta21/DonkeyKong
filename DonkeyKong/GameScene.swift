//
//  GameScene.swift
//  DonkeyKong
//
//  Created by soham gupta on 1/18/22.
//

import Foundation
import SpriteKit
import GameKit
import SwiftUI

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let player = SKShapeNode(rectOf: CGSize(width: 50, height: 50))
    var donkeyKong = SKShapeNode()
    var princess = SKShapeNode()
    
    var barrelTimer = Timer()
    
    let joystick = TLAnalogJoystick(withDiameter: 100)
    let jumpButton = SKShapeNode(circleOfRadius: 100)
    
    var ladders : [SKShapeNode] = []
    
    var platforms : [SKShapeNode] = []
    var endPlatform : SKShapeNode = SKShapeNode()
    
    let platformCategory: UInt32 = 0x1 << 0
    let ladderCategory: UInt32 = 0x1 << 1
    let playerCategory: UInt32 = 0x1 << 2
    
    var climbingLadder : Bool = false
    
    override func didMove(to view: SKView) {
        anchorPoint = .zero
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        
        // creates the platforms

        platforms.append(createPlatform(x: size.width / 3, y: size.height / 6, rotation: -CGFloat.pi / 48))
        platforms.append(createPlatform(x: size.width * 2 / 3, y: size.height * 2 / 6, rotation: CGFloat.pi / 48))
        platforms.append(createPlatform(x: size.width / 3, y: size.height * 3 / 6, rotation: -CGFloat.pi / 48))
        platforms.append(createPlatform(x: size.width * 2 / 3, y: size.height * 4 / 6, rotation: CGFloat.pi / 48))
        platforms.append(createPlatform(x: size.width / 3, y: size.height * 5 / 6, rotation: -CGFloat.pi / 48))
                
        endPlatform = createEndPlatform()
        
        // creates the ladders
        let ladderHeight = 200
        
        ladders.append(createLadder(x: size.width / 3, y: size.height / 6 + CGFloat(ladderHeight) / 2, height: 250))
        ladders.append(createLadder(x: size.width * 2 / 3, y: size.height * 2 / 6 + CGFloat(ladderHeight) / 2, height : 250))
        ladders.append(createLadder(x: size.width / 3, y: size.height * 3 / 6 + CGFloat(ladderHeight) / 2, height : 250))
        ladders.append(createLadder(x: size.width * 2 / 3, y: size.height * 4 / 6 + CGFloat(ladderHeight) / 2, height : 250))
        ladders.append(createLadder (x: size.width / 3, y: size.height * 5 / 6 + CGFloat(ladderHeight) / 2 - 50, height : 75))
        
        // create the player
        createPlayer()
        donkeyKong = createStaticPlayer(x: size.width / 4, y: size.height * 9 / 10, size: 125)
        princess = createStaticPlayer(x: size.width / 2, y: size.height * 8 / 9 + 50, size: 50)

        // https://github.com/MitrofD/TLAnalogJoystick
        
        joystick.position = CGPoint(x: size.width / 5, y: size.height / 10)
        addChild(joystick)
        
        joystick.on(.move) { [unowned self] joystick in
            player.physicsBody?.affectedByGravity = true
            if joystick.angular > -0.75 && joystick.angular < 0.75 {
                climbingLadder = false
                for ladder in ladders {
                    if positionBasedCollision(nodeA: player, nodeB: ladder) {
                        climbingLadder = true
                    }
                }
                if climbingLadder {
                    player.physicsBody?.affectedByGravity = false
                    player.physicsBody?.collisionBitMask = 0x1 << 5
                    player.position.y += 2
                } else {
                    player.physicsBody?.collisionBitMask = platformCategory
                    player.physicsBody?.affectedByGravity = true
                }
            } else if joystick.angular > 0.75 && joystick.angular < 2.25 {
                player.position.x -= 2
            } else if abs(joystick.angular) > 2.25 {
            } else {
                player.position.x += 2
            }
            
        }
                
        joystick.on(.end) { [unowned self] _ in
            print("end")
        }
        
        jumpButton.position = CGPoint(x: size.width * 4 / 5, y: size.height / 10)
        jumpButton.name = "Jump"
        addChild(jumpButton)
        
//
//        barrelTimer = .scheduledTimer(timeInterval: 5, target: self,
//                                                selector:#selector(addChild(createBarrels(radius: 30))),
//                                                userInfo: nil,
//                                                repeats: true)
        
        for platform in platforms{
            platform.physicsBody?.categoryBitMask = platformCategory
        }
        endPlatform.physicsBody?.categoryBitMask = platformCategory
        player.physicsBody?.collisionBitMask = platformCategory
        player.physicsBody?.categoryBitMask = playerCategory
        for ladder in ladders {
            ladder.physicsBody?.categoryBitMask = ladderCategory
            ladder.physicsBody?.contactTestBitMask = playerCategory
        }
        
        
            
    }
    
    func createPlayer() {
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 50))
        player.fillColor = SKColor.green
        player.position = CGPoint(x:size.width / 2, y:size.width / 2)
//
//        player.physicsBody?.categoryBitMask = 2
//        player.physicsBody?.contactTestBitMask = 0
        player.physicsBody?.friction = 0.7
        
        self.addChild(player)
    }
    
    func createBarrels(radius : CGFloat) -> SKShapeNode {
        let barrel = SKShapeNode(circleOfRadius: radius)
        
        barrel.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        barrel.fillColor = SKColor.orange
        barrel.position = CGPoint(x: size.width / 2, y: size.height * 9 / 10)
//        barrel.physicsBody?.categoryBitMask = 1
//        barrel.physicsBody?.contactTestBitMask = 0
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
//        rect.physicsBody?.contactTestBitMask = 1
//        rect.physicsBody?.collisionBitMask = 0
        
        //rect.physicsBody?.pinned = true
        
        self.addChild(rect)
        
        return rect
    }
    
    func createEndPlatform() -> SKShapeNode {
        let rect = SKShapeNode(rectOf: CGSize(width: 200, height: 25))
        
        rect.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 200, height: 25))
        rect.fillColor = SKColor.brown
        rect.position = CGPoint(x: size.width / 2, y: size.height * 8 / 9 )
        rect.physicsBody?.affectedByGravity = false
        rect.physicsBody?.isDynamic = false
        
        self.addChild(rect)
        
        return rect
    }
    
    func createStaticPlayer(x: CGFloat, y: CGFloat, size: CGFloat) -> SKShapeNode {
        let player = SKShapeNode(rectOf: CGSize(width: size, height: size))
        
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size, height: size))
        player.fillColor = SKColor.purple
        player.position = CGPoint(x: x, y: y)
        
        self.addChild(player)
        
        return player
    }
    
    func createLadder(x: CGFloat, y: CGFloat, height: CGFloat) -> SKShapeNode {
        let rect = SKShapeNode(rectOf: CGSize(width: 50, height: height))
        
        rect.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: height))
        rect.fillColor = SKColor.cyan
        rect.position = CGPoint(x: x, y: y)
        rect.physicsBody?.affectedByGravity = false
        rect.physicsBody?.isDynamic = false
        
        self.addChild(rect)
        
        return rect
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
//        guard let nodeA = contact.bodyA.node else {return}
//        guard let nodeB = contact.bodyB.node else {return}
//
//        if nodeA == player {
//            print("collision")
//        } else {
//            print("no collision")
//        }
        
        let collision: UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == playerCategory | ladderCategory {
            print("Ladder Collision")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            if touchedNode.name == "Jump" {
                player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 75))
            }
        }
    }
    
    func positionBasedCollision(nodeA: SKNode, nodeB: SKNode) -> Bool{
        var xBool = false
        var yBool = false
        
        if nodeA.position.x > CGFloat(nodeB.position.x - nodeB.frame.width / 2) && nodeA.position.x < CGFloat(nodeB.position.x + nodeB.frame.width / 2) {
            xBool = true
        }
        
        if nodeA.position.y > CGFloat(nodeB.position.y - nodeB.frame.height / 2) && nodeA.position.y < CGFloat(nodeB.position.y + nodeB.frame.height / 2) {
            yBool = true
        }
        
        return xBool && yBool
    }
    

}
