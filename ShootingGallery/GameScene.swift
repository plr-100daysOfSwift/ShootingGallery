//
//  GameScene.swift
//  ShootingGallery
//
//  Created by Paul Richardson on 20/05/2021.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    override func didMove(to view: SKView) {

			let background = SKSpriteNode(imageNamed: "wood-background")
			background.position = CGPoint(x: 512, y: 384)
			background.blendMode = .replace
			background.scale(to: view.frame.size)
			background.zPosition = -1
			addChild(background)

			let curtains = SKSpriteNode(imageNamed: "curtains")
			curtains.position = CGPoint(x: 512, y: 384)
			curtains.blendMode = .alpha
			curtains.scale(to: view.frame.size)
			curtains.zPosition = 10
			addChild(curtains)

			let waterBackground = SKSpriteNode(imageNamed: "water-bg")
			waterBackground.position = CGPoint(x: 512, y: 110)
			waterBackground.zPosition = 1
			addChild(waterBackground)

			let waterForeground = SKSpriteNode(imageNamed: "water-fg")
			waterForeground.position = CGPoint(x: 512, y: 110)
			waterForeground.zPosition = 3
			addChild(waterForeground)

			let target = SKSpriteNode(imageNamed: "target3")
			target.position = CGPoint(x: 512, y: 260)
			target.zPosition = 2
			target.name = "target"
			addChild(target)
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

		}

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
