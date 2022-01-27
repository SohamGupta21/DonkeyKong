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
    
    var gameOver = false
    var livesCount = 3
    var jumpAllowed = true
    
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
    
    let joystick = TLAnalogJoystick(withDiameter: 150)
    let jumpButton = SKShapeNode(circleOfRadius: 100)
    
    var backgroundMusic : SKAudioNode!
    
    var ladders : [SKSpriteNode] = []
    var platforms : [SKSpriteNode] = []
    var barrels : [SKSpriteNode] = []
    var hearts : [SKSpriteNode] = []
    
    let platformCategory: UInt32 = 0x1 << 0
    let ladderCategory: UInt32 = 0x1 << 1
    let playerCategory: UInt32 = 0x1 << 2
    let barrelCategory: UInt32 = 0x1 << 3
    let princessCategory: UInt32 = 0x1 << 4
    
    var climbingLadder : Bool = false
    
    
    override func didMove(to view: SKView) {
        anchorPoint = .zero
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        self.backgroundColor = .black
        self.scaleMode = .aspectFit
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        //self.physicsBody?.categoryBitMask = 0x1 << 5
        self.physicsBody?.contactTestBitMask = barrelCategory
        //set the animations:
        let marioRightWalkAnimation = SKAction.animate(with: marioWalkRightTextures, timePerFrame: 0.325)
        let marioLeftWalkAnimation = SKAction.animate(with: marioWalkLeftTextures, timePerFrame: 0.325)
        let marioJumpAnimation = SKAction.animate(with: marioJumpTextures, timePerFrame: 0.325)
        
        
        // playMusic()
        
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
        
        // create the hearts
        
        for i in 1...3 {
            var heart = SKSpriteNode(imageNamed: "Heart")
            
            heart.position = CGPoint(x: CGFloat(20 * i), y: size.height * 9 / 10)
            heart.setScale(0.1)
            hearts.append(heart)
            
            self.addChild(heart)
        }
        
        // create mario
        createPlayer()
        player.setScale(0.25)
        
        
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
                var aboveHalfway = false
                for ladder in ladders {
                    if positionBasedCollision(nodeA: player, nodeB: ladder) {
                        climbingLadder = true
                        
                        if player.position.y > ladder.position.y {
                            aboveHalfway = true
                        }
                    }
                }
                if climbingLadder {
                    player.physicsBody?.affectedByGravity = false
                    if aboveHalfway {
                        player.physicsBody?.collisionBitMask = 0x1 << 16
                    }
                    player.position.y += SettingsClass.shared.marioSpeed
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
                player.position.x -= SettingsClass.shared.marioSpeed
            } else if abs(joystick.angular) > 2.25 {
                // down
            } else {
                // right
                if currentMarioAnimation != "right" {
                    player.run(SKAction.repeatForever(marioRightWalkAnimation))
                    currentMarioAnimation = "right"
                }
                player.position.x += SettingsClass.shared.marioSpeed
            }
            
        }
                
        joystick.on(.end) { [unowned self] _ in
            player.removeAllActions()
        }
        
        jumpButton.position = CGPoint(x: size.width * 4 / 5, y: size.height / 10)
        jumpButton.name = "Jump"
        addChild(jumpButton)
        

        barrelTimer = .scheduledTimer(timeInterval: SettingsClass.shared.barrelTimer, target: self,
                                                selector:#selector(createBarrels),
                                                userInfo: nil,
                                                repeats: true)
        //addChild(createBarrels(radius: 20))
        for platform in platforms{
            platform.physicsBody?.categoryBitMask = platformCategory
            platform.physicsBody?.contactTestBitMask = playerCategory
        }
        player.physicsBody?.collisionBitMask = platformCategory
        player.physicsBody?.categoryBitMask = playerCategory
        for ladder in ladders {
            ladder.physicsBody?.categoryBitMask = ladderCategory
            ladder.physicsBody?.contactTestBitMask = playerCategory
        }
        
        
            
    }
    
    override func update(_ currentTime: TimeInterval) {
        if player.position.y < 100 {
            print("player has fallen")
            player.removeFromParent()
            gameOverSequence()
        }
        for n in 0..<barrels.count {
            var b = barrels[n]
            if b.position.y < 100 {
                print("Barrel has fallen")
                barrels[n].removeFromParent()
            }
        }
    }
    
    func createPlayer() {
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: player.size.width, height: player.size.height))
        player.position = CGPoint(x:size.width / 2, y:size.width / 2 - 100)
        player.physicsBody?.friction = 0.7
        
        self.addChild(player)
    }
    
    @objc func createBarrels() {
        if !gameOver {
            let radius = CGFloat(20)
            
            let barrel = SKSpriteNode(imageNamed: "Barrel")
            
            barrel.physicsBody = SKPhysicsBody(circleOfRadius: radius)
            barrel.size = CGSize(width: radius * 2, height: radius * 2)
            barrel.position = CGPoint(x: size.width * 5 / 6, y: size.height * 9 / 10)
            barrel.physicsBody?.friction = 0.7
            
            barrel.physicsBody?.categoryBitMask = barrelCategory
            barrel.physicsBody?.collisionBitMask = platformCategory
            barrel.physicsBody?.contactTestBitMask = playerCategory
            
            barrel.physicsBody?.mass = 1
            barrel.physicsBody?.friction = 50
            
            barrels.append(barrel)
            
            self.addChild(barrel)
        }
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
        
        player.physicsBody?.categoryBitMask = princessCategory
        player.physicsBody?.contactTestBitMask = playerCategory
        
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
        
        let collision: UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == playerCategory | ladderCategory {
            print("Ladder Collision")
        }
        
        if collision == barrelCategory | playerCategory {
            print("Barrels collision")
            livesCount -= 1
            hearts[hearts.count - 1].removeFromParent()
            hearts.removeLast()
            
            if livesCount == 0 {
                gameOverSequence()
            }
            //gameOverSequence()
        }
        
        if collision == princessCategory | playerCategory {
            print("Princess is saved")
            gameWinSequence()
        }
        
        if collision == platformCategory | playerCategory {
            jumpAllowed = true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            if touchedNode.name == "Jump" && jumpAllowed {
                jumpAllowed = false
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
    

    
    func gameOverSequence(){
        
        gameOver = true
 
        player.removeFromParent()
        let gameOverLabel       = SKLabelNode(fontNamed: "Chalkduster")
        gameOverLabel.position  = CGPoint(x: size.width / 2, y: size.height / 2)
        gameOverLabel.zPosition = 10
        gameOverLabel.text      = "Game Over"
        addChild(gameOverLabel)
    }
    
    func gameWinSequence() {
        gameOver = true
        
        player.removeFromParent()
        let gameWon       = SKLabelNode(fontNamed: "Chalkduster")
        gameWon.position  = CGPoint(x: size.width / 2, y: size.height / 2)
        gameWon.zPosition = 10
        gameWon.text      = "Level Passed"
        addChild(gameWon)
    }
    
    func playMusic() {
        if let musicURL = Bundle.main.url(forResource: "Title", withExtension: "mp3") {
            backgroundMusic = SKAudioNode(url: musicURL)
            self.addChild(backgroundMusic)
        }
    }
}
