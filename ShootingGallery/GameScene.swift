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

		makeTarget()

	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else { return }
		let location = touch.location(in: self)
		let tappedNodes = nodes(at: location)
		for node in tappedNodes {
			if node.name == "target" {
				run(.playSoundFileNamed("shot", waitForCompletion: false))
			}
		}

	}

	override func update(_ currentTime: TimeInterval) {
		for node in children {
			if node.position.x > 1200 {
				node.removeFromParent()
			}
		}
	}

	func makeTarget() {
		let target = SKSpriteNode(imageNamed: "target3")
		target.position = CGPoint(x: -300, y: 235)
		target.zPosition = 2
		target.name = "target"
		addChild(target)

		target.physicsBody = SKPhysicsBody(circleOfRadius: target.size.width / 2)
		target.physicsBody?.isDynamic = true
		target.physicsBody?.allowsRotation = false
		target.physicsBody?.affectedByGravity = false
		target.physicsBody?.velocity = CGVector(dx: 500, dy: 0)
	}
}
