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
    
    var player = SKSpriteNode(imageNamed: "marioL1")
    var donkeyKong = SKSpriteNode()
    var princess = SKSpriteNode(imageNamed: "princess1")
    
    let donkeyKongTextures = [SKTexture(image: #imageLiteral(resourceName: "dk1")), SKTexture(image: #imageLiteral(resourceName: "dk2"))]
    let princessTextures = [SKTexture(image: #imageLiteral(resourceName: "princess1")), SKTexture(image: #imageLiteral(resourceName: "princess2"))]
    
    let marioWalkRightTextures = [SKTexture(image: #imageLiteral(resourceName: "marioR1")), SKTexture(image: #imageLiteral(resourceName:"marioR2"))]
    let marioWalkLeftTextures = [SKTexture(image: #imageLiteral(resourceName: "marioL1")), SKTexture(image: #imageLiteral(resourceName:"marioL2"))]
    let marioJumpTextures = [SKTexture(image: #imageLiteral(resourceName: "marioclimb1")), SKTexture(image: #imageLiteral(resourceName:"marioclimb2"))]
    
    var currentMarioAnimation = ""
    
    var barrelTimer = Timer()
    
    let joystick = TLAnalogJoystick(withDiameter: 100)
    let jumpButton = SKShapeNode(circleOfRadius: 100)
    
    var ladders : [SKSpriteNode] = []
    
    var platforms : [SKSpriteNode] = []
    
    let platformCategory: UInt32 = 0x1 << 0
    let ladderCategory: UInt32 = 0x1 << 1
    let playerCategory: UInt32 = 0x1 << 2
    let barrelCategory: UInt32 = 0x1 << 3
    
    var climbingLadder : Bool = false
    
    override func didMove(to view: SKView) {
        anchorPoint = .zero
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        self.backgroundColor = .black
        self.scaleMode = .aspectFit
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        
        //set the animations:
        let marioRightWalkAnimation = SKAction.animate(with: marioWalkRightTextures, timePerFrame: 0.325)
        let marioLeftWalkAnimation = SKAction.animate(with: marioWalkLeftTextures, timePerFrame: 0.325)
        let marioJumpAnimation = SKAction.animate(with: marioJumpTextures, timePerFrame: 0.325)
        
        // creates the platforms

        platforms.append(createPlatform(x: size.width / 3, y: size.height / 6, rotation: -CGFloat.pi / 48))
        platforms.append(createPlatform(x: size.width * 2 / 3, y: size.height * 2 / 6, rotation: CGFloat.pi / 48))
        platforms.append(createPlatform(x: size.width / 3, y: size.height * 3 / 6, rotation: -CGFloat.pi / 48))
        platforms.append(createPlatform(x: size.width * 2 / 3, y: size.height * 4 / 6, rotation: CGFloat.pi / 48))
        platforms.append(createPlatform(x: size.width / 3, y: size.height * 5 / 6, rotation: -CGFloat.pi / 48))
                
        // create the borders
        
        
        
        // creates the ladders
        let ladderHeight = 200
        
        ladders.append(createLadder(x: size.width / 3, y: size.height / 6 + CGFloat(ladderHeight) / 2, height: 250))
        ladders.append(createLadder(x: size.width * 2 / 3, y: size.height * 2 / 6 + CGFloat(ladderHeight) / 2, height : 250))
        ladders.append(createLadder(x: size.width / 3, y: size.height * 3 / 6 + CGFloat(ladderHeight) / 2, height : 250))
        ladders.append(createLadder(x: size.width * 2 / 3, y: size.height * 4 / 6 + CGFloat(ladderHeight) / 2, height : 250))
        
        // create mario
        createPlayer()
        player.setScale(0.5)
        
        
        // donkey kong
        donkeyKong = createDonkeyKong(x: size.width / 4, y: size.height * 9 / 10, size: 125)
        
        let dkAnimation = SKAction.animate(with: donkeyKongTextures, timePerFrame: 0.4)
        
        donkeyKong.run(SKAction.repeatForever(dkAnimation))
        
        princess = createPrincess(x: size.width / 2, y: size.height * 8 / 9 + 50, size: 50)
        
        let princessAnimation = SKAction.animate(with: princessTextures, timePerFrame: 0.4)
        
        princess.run(SKAction.repeatForever(princessAnimation))
        
        // https://github.com/MitrofD/TLAnalogJoystick
        
        joystick.position = CGPoint(x: size.width / 5, y: size.height / 10)
        addChild(joystick)
        
        joystick.on(.move) { [unowned self] joystick in
            player.physicsBody?.affectedByGravity = true
            if joystick.angular > -0.75 && joystick.angular < 0.75 {
                // up
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
                    if currentMarioAnimation != "up" {
                        player.run(SKAction.repeatForever(marioJumpAnimation))
                        currentMarioAnimation = "up"
                    }
                } else {
                    player.physicsBody?.collisionBitMask = platformCategory
                    player.physicsBody?.affectedByGravity = true
                }
            } else if joystick.angular > 0.75 && joystick.angular < 2.25 {
                // left
                if currentMarioAnimation != "left" {
                    player.run(SKAction.repeatForever(marioLeftWalkAnimation))
                    currentMarioAnimation = "left"
                }
                player.position.x -= 2
            } else if abs(joystick.angular) > 2.25 {
                // down
            } else {
                // right
                if currentMarioAnimation != "right" {
                    player.run(SKAction.repeatForever(marioRightWalkAnimation))
                    currentMarioAnimation = "right"
                }
                player.position.x += 2
            }
            
        }
                
        joystick.on(.end) { [unowned self] _ in
            player.removeAllActions()
        }
        
        jumpButton.position = CGPoint(x: size.width * 4 / 5, y: size.height / 10)
        jumpButton.name = "Jump"
        addChild(jumpButton)
        

        barrelTimer = .scheduledTimer(timeInterval: 5, target: self,
                                                selector:#selector(createBarrels),
                                                userInfo: nil,
                                                repeats: true)
        //addChild(createBarrels(radius: 20))
        for platform in platforms{
            platform.physicsBody?.categoryBitMask = platformCategory
        }
        player.physicsBody?.collisionBitMask = platformCategory
        player.physicsBody?.categoryBitMask = playerCategory
        for ladder in ladders {
            ladder.physicsBody?.categoryBitMask = ladderCategory
            ladder.physicsBody?.contactTestBitMask = playerCategory
        }
        
        
            
    }
    
    func createPlayer() {
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: player.size.width, height: player.size.height))
        player.position = CGPoint(x:size.width / 2, y:size.width / 2 - 100)
        player.physicsBody?.friction = 0.7
        
        self.addChild(player)
    }
    
    @objc func createBarrels() {
        let radius = CGFloat(20)
        
        let barrel = SKSpriteNode(imageNamed: "Barrel")
        
        barrel.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        barrel.size = CGSize(width: radius * 2, height: radius * 2)
        barrel.position = CGPoint(x: size.width * 5 / 6, y: size.height * 9 / 10)
        barrel.physicsBody?.friction = 0.7
        
        barrel.physicsBody?.categoryBitMask = barrelCategory
        barrel.physicsBody?.collisionBitMask = platformCategory
        
        barrel.physicsBody?.mass = 1
        barrel.physicsBody?.friction = 50
        
        self.addChild(barrel)
    }
    
    func createPlatform(x: CGFloat, y: CGFloat,rotation: CGFloat) -> SKSpriteNode {
        let rect = SKSpriteNode(imageNamed: "Platform")
        
        rect.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 650, height: 25))
        rect.size = CGSize(width: 650, height: 25)
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
    
    func createDonkeyKong(x: CGFloat, y: CGFloat, size: CGFloat) -> SKSpriteNode {
        let player = SKSpriteNode(imageNamed: "kong1")
        
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size, height: size))
        // player.fillColor = SKColor.purple
        player.position = CGPoint(x: x, y: y)
        player.texture  = SKTexture(image: #imageLiteral(resourceName: "kong1"))
        
        self.addChild(player)
        
        return player
    }
    
    func createPrincess(x: CGFloat, y: CGFloat, size: CGFloat) -> SKSpriteNode {
        let player = SKSpriteNode(imageNamed: "princess1")
        
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size, height: size))
        // player.fillColor = SKColor.purple
        player.position = CGPoint(x: x, y: y)
        player.size = CGSize(width: 50, height: 60)
        self.addChild(player)
        
        return player
    }
    
    func createLadder(x: CGFloat, y: CGFloat, height: CGFloat) -> SKSpriteNode {
        let rect = SKSpriteNode(imageNamed: "Ladder (1)")
        
        rect.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: height))
        rect.size = CGSize(width: 50, height: height)
       /// rect.fillColor = SKColor.cyan
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
                player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 800))
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
