//
//  GameOverlay.swift
//  SuperSpaceMan3D
//
//  Created by MCUCSIE on 7/15/17.
//  Copyright © 2017 MCUCSIE. All rights reserved.
//

import SceneKit
import SpriteKit

class GameOverlay: SKScene {
    var timerNode: SKLabelNode!
    var scoreNode: SKLabelNode!
    var timerFormat: NumberFormatter!
    var score: Int!{
        set {
            scoreNode.text = String(newValue)
        }

        get {
            return Int(scoreNode.text!)
        }
    }

    override init(size: CGSize) {
        super.init(size: size)

        anchorPoint = CGPoint(x: 0, y: 0.5)
        scaleMode = .resizeFill

        timerNode = SKLabelNode(fontNamed: "AvenirNext-Bold")
        timerNode.text = "Time: 0.0"
        timerNode.fontColor = .red
        timerNode.horizontalAlignmentMode = .left
        timerNode.verticalAlignmentMode = .bottom
        timerNode.position = CGPoint(x: 0, y: size.height / 2 - 40)
        timerNode.name = "timer"

        addChild(timerNode)

        scoreNode = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreNode.text = "0"
        scoreNode.fontColor = .red
        scoreNode.horizontalAlignmentMode = .left
        scoreNode.verticalAlignmentMode = .bottom
        scoreNode.position = CGPoint(x: 0, y: size.height / 4 + 20)

        addChild(scoreNode)

        timerFormat = NumberFormatter()
        timerFormat.numberStyle = .decimal
        timerFormat.minimumFractionDigits = 1
        timerFormat.maximumFractionDigits = 1
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startTimer() {
        let startTime = NSDate.timeIntervalSinceReferenceDate
        let timerNode = childNode(withName: "timer") as! SKLabelNode

        let timerAction = SKAction.run {
            let now = NSDate.timeIntervalSinceReferenceDate
            let elapsedTime = TimeInterval(now - startTime)
            let tempString = String(format: "%@", self.timerFormat.string(from: NSNumber(value: elapsedTime))!)

            timerNode.text = "Time: " + tempString
        }
        let startDelay = SKAction.wait(forDuration: 0.5)
        let timerDelay = SKAction.sequence([timerAction, startDelay])
        let timer = SKAction.repeatForever(timerDelay)

        timerNode.run(timer, withKey: "timerAction")
    }

    func stopTimer() {
        let timerNode = childNode(withName: "timer") as! SKLabelNode

        timerNode.removeAction(forKey: "timerAction")
    }
}
