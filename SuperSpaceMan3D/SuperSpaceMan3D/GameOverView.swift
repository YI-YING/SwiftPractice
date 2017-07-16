//
//  GameOverView.swift
//  SuperSpaceMan3D
//
//  Created by MCUCSIE on 7/15/17.
//  Copyright © 2017 MCUCSIE. All rights reserved.
//

import SpriteKit

protocol GameOverViewDelegate: NSObjectProtocol {
    func gameOverViewTouchBegan(_ touches: Set<UITouch>, with event: UIEvent?) -> Void
}

class GameOverView: SKScene {
    var gameOverViewDelegate: GameOverViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(size: CGSize, score: String) {
        super.init(size: size)

        backgroundColor = .red
        let backgroundNode = SKSpriteNode(imageNamed: "GameOverBackground")
        backgroundNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundNode.position = CGPoint(x: 160, y: 0)

        addChild(backgroundNode)

        let scoreTextNode = SKLabelNode(fontNamed: "Copperplate")
        scoreTextNode.text = "SCORE : \(score)"
        scoreTextNode.horizontalAlignmentMode = .center
        scoreTextNode.verticalAlignmentMode = .center
        scoreTextNode.fontSize = 20
        scoreTextNode.color = .white
        scoreTextNode.position = CGPoint(x: size.width / 2, y: size.height - 75)

        addChild(scoreTextNode)

        let tryAgainText = SKLabelNode(fontNamed: "Copperplate")
        tryAgainText.text = "TAP ANYWHERE TO PLAY AGAIN!"
        tryAgainText.horizontalAlignmentMode = .center
        tryAgainText.verticalAlignmentMode = .center
        tryAgainText.fontSize = 20
        tryAgainText.color = .white
        tryAgainText.position = CGPoint(x: size.width / 2, y: size.height - 200)

        addChild(tryAgainText)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.gameOverViewDelegate?.gameOverViewTouchBegan(touches, with: event)
    }
}
