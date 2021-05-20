//
//  GameScene.swift
//  ShootingGallery
//
//  Created by Paul Richardson on 20/05/2021.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {

	var gameTimer: Timer?
	var gameLength = 60
	var timeRemaining: Int!
	var timeRemainingLabel: SKLabelNode!
	var isFullSecond: Bool = false {
		didSet(fullSecond) {
			if fullSecond == true {
				timeRemaining -= 1
				if timeRemaining == 0 {
					finishGame()
					return
				}
				timeRemainingLabel.text = String(timeRemaining)
			}
		}
	}

	let playReload = SKAction.playSoundFileNamed("reload", waitForCompletion: false)
	let playShot = SKAction.playSoundFileNamed("shot", waitForCompletion: false)
	let playEmpty = SKAction.playSoundFileNamed("empty", waitForCompletion: false)

	let centrePoint = CGPoint(x: 512, y: 384)

	var score = 0 {
		didSet {
			scoreLabel.text = "Score: \(score)"
		}
	}

	var shotsUsed = 0 {
		didSet {
			if shotsUsed < 4 {
				holster1.texture = shots[shotsUsed]
			} else {
				holster2.texture = shots[shotsUsed]
			}
		}
	}

	var scoreLabel: SKLabelNode!

	let shots = [
		SKTexture(imageNamed: "shots0"),
		SKTexture(imageNamed: "shots1"),
		SKTexture(imageNamed: "shots2"),
		SKTexture(imageNamed: "shots3"),
		SKTexture(imageNamed: "shots1"),
		SKTexture(imageNamed: "shots2"),
		SKTexture(imageNamed: "shots3"),
	]

	var holster1: SKSpriteNode!
	var holster2: SKSpriteNode!

	override func didMove(to view: SKView) {

		timeRemaining = gameLength

		let background = SKSpriteNode(imageNamed: "wood-background")
		background.position = centrePoint
		background.blendMode = .replace
		background.scale(to: view.frame.size)
		background.zPosition = -1
		addChild(background)

		let curtains = SKSpriteNode(imageNamed: "curtains")
		curtains.position = centrePoint
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

		let holsterPadding = shots[0].size().width / 2 + 3.5

		holster1 = SKSpriteNode(texture: shots[0])
		holster1.position = CGPoint(x: 512 - holsterPadding, y: 50)
		holster1.zPosition = 20
		addChild(holster1)

		holster2 = SKSpriteNode(texture: shots[0])
		holster2.position = CGPoint(x: 512 + holsterPadding, y: 50)
		holster2.zPosition = 20
		addChild(holster2)

		scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
		scoreLabel.position = CGPoint(x: 20, y: 720)
		scoreLabel.text = "Score: 0"
		scoreLabel.horizontalAlignmentMode = .left
		scoreLabel.zPosition = 20
		addChild(scoreLabel)


		timeRemainingLabel = SKLabelNode(fontNamed: "Chalkduster")
		timeRemainingLabel.text = String(timeRemaining)
		timeRemainingLabel.fontSize = 48
		timeRemainingLabel.position = CGPoint(x: 990, y: 720)
		timeRemainingLabel.horizontalAlignmentMode = .right
		timeRemainingLabel.zPosition = 20
		addChild(timeRemainingLabel)

		gameTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { _ in
			self.makeTarget()
			self.isFullSecond.toggle()
		})

	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else { return }
		guard  timeRemaining > 0 else { return }

		if shotsUsed < 6 {
			shotsUsed += 1
			run(playShot)
			let location = touch.location(in: self)
			let tappedNodes = nodes(at: location)
			for node in tappedNodes {
				if node.name == "target" {
					score += 1
				}
			}
		} else {
			run(playEmpty)
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

	func finishGame() {
		gameTimer?.invalidate()
		let gameOver = SKSpriteNode(imageNamed: "game-over")
		gameOver.position = centrePoint
		gameOver.zPosition = 10
		addChild(gameOver)

		timeRemainingLabel?.removeFromParent()
	}
}
