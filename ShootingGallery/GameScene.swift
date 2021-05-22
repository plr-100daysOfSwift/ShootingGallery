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
			switch shotsUsed {
			case 0:
				holster1.texture = shots[shotsUsed]
				holster2.texture = shots[shotsUsed]
			case 1 ... 3:
				holster1.texture = shots[shotsUsed]
			case 4 ... 5:
				holster2.texture = shots[shotsUsed]
			case 6:
				holster2.texture = shots[shotsUsed]
				addChild(reloadLabel)
			default:
				return
			}
		}
	}

	var ducks = [String]()
	var targets = [String]()


	var scoreLabel: SKLabelNode!
	var reloadLabel: SKLabelNode!

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

		ducks = ["target1", "target2", "target3"]
		targets =  ["target0"] + ducks

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
		curtains.zPosition = 90
		addChild(curtains)

		addGrass()

		addWater()

		let holsterPadding = shots[0].size().width / 2 + 3.5

		holster1 = SKSpriteNode(texture: shots[0])
		holster1.position = CGPoint(x: 512 - holsterPadding, y: 50)
		holster1.zPosition = 100
		addChild(holster1)

		holster2 = SKSpriteNode(texture: shots[0])
		holster2.position = CGPoint(x: 512 + holsterPadding, y: 50)
		holster2.zPosition = 100
		addChild(holster2)

		scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
		scoreLabel.position = CGPoint(x: 20, y: 720)
		scoreLabel.text = "Score: 0"
		scoreLabel.fontSize = 48
		scoreLabel.horizontalAlignmentMode = .left
		scoreLabel.zPosition = 100
		addChild(scoreLabel)

		reloadLabel = SKLabelNode(fontNamed: "Chalkduster")
		reloadLabel.name = "reload"
		reloadLabel.text = "Reload!"
		reloadLabel.fontSize = 48
		reloadLabel.position = CGPoint(x: 150, y: 30)
		reloadLabel.horizontalAlignmentMode = .left
		reloadLabel.zPosition = 100

		timeRemainingLabel = SKLabelNode(fontNamed: "Chalkduster")
		timeRemainingLabel.text = String(timeRemaining)
		timeRemainingLabel.fontSize = 48
		timeRemainingLabel.position = CGPoint(x: 990, y: 720)
		timeRemainingLabel.horizontalAlignmentMode = .right
		timeRemainingLabel.zPosition = 100
		addChild(timeRemainingLabel)

		gameTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { _ in
			self.makeDuckTarget()
			self.isFullSecond.toggle()
			let x = Int.random(in: 0 ... 10)
			if x == 0 { self.makeBullsEyeTarget() }
		})

	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else { return }
		guard  timeRemaining > 0 else { return }

		let location = touch.location(in: self)
		let tappedNodes = nodes(at: location)

		if shotsUsed < 6 {
			shotsUsed += 1
			run(playShot)
			for node in tappedNodes {
				if node.name?.prefix(6) == "target" {
					switch node.name {
					case targets[3]:
						score += 1
					case targets[2]:
						score -= 1
					case targets[0]:
						score += 5
					default:
						break
					}
					let fade = SKAction.fadeOut(withDuration: 0.5)
					let remove = SKAction.removeFromParent()
					node.run(SKAction.sequence([fade, remove]))
				}
			}
		} else {
			for node in tappedNodes {
				if node.name == "reload" {
					reload()
					return
				}
			}
			run(playEmpty)
		}

	}

	fileprivate func addGrass() {

		let grassNode = SKNode()
		addChild(grassNode)

		let positionX: CGFloat = 512
		let positionY: CGFloat = 340
		let zPosition:CGFloat = 10

		let grass = SKSpriteNode(imageNamed: "grass-trees")
		grass.position = CGPoint(x: positionX, y: positionY)
		grass.zPosition = zPosition
		grassNode.addChild(grass)

		let offset = grass.size.width

		let grassLeft = SKSpriteNode(imageNamed: "grass-trees")
		grassLeft.position =  CGPoint(x: positionX - offset, y: positionY)
		grassLeft.zPosition = zPosition
		grassNode.addChild(grassLeft)

		let grassRight = SKSpriteNode(imageNamed: "grass-trees")
		grassRight.position = CGPoint(x: positionX + offset, y: positionY)
		grassRight.zPosition = zPosition
		grassNode.addChild(grassRight)

	}

	fileprivate func addWater() {

		let waterBackgroundNode = SKNode()
		addChild(waterBackgroundNode)

		let tilingCorrection: CGFloat = -4 // images don't tile exactly
		let positionX: CGFloat = 512

		var positionY: CGFloat = 170
		var zPosition:CGFloat = 20

		// background

		let backgroundTexture = SKTexture(imageNamed: "water-bg")
		let offset = (backgroundTexture.size().width / 2) + tilingCorrection

		let waterBackgroundLeft = SKSpriteNode(texture: backgroundTexture)
		waterBackgroundLeft.position = CGPoint(x: positionX - offset, y: positionY)
		waterBackgroundLeft.zPosition = zPosition
		waterBackgroundNode.addChild(waterBackgroundLeft)

		let waterBackgroundRight = SKSpriteNode(texture: backgroundTexture)
		waterBackgroundRight.position = CGPoint(x: positionX + offset, y: positionY)
		waterBackgroundRight.zPosition = zPosition

		waterBackgroundNode.addChild(waterBackgroundRight)

		// foreground

		let waterForegroundNode = SKNode()
		addChild(waterForegroundNode)

		positionY = 120
		zPosition = 30

		let foregroundTexture = SKTexture(imageNamed: "water-fg")

		let waterForegroundLeft = SKSpriteNode(texture: foregroundTexture)
		waterForegroundLeft.position = CGPoint(x: positionX - offset, y: positionY)
		waterForegroundLeft.zPosition = zPosition
		waterForegroundNode.addChild(waterForegroundLeft)

		let waterForegroundRight = SKSpriteNode(texture: foregroundTexture)
		waterForegroundRight.position = CGPoint(x: positionX + offset, y: positionY)
		waterForegroundRight.zPosition = zPosition
		waterForegroundNode.addChild(waterForegroundRight)

	}

	func makeDuckTarget() {

		let targetName = ducks.randomElement()!

		let target = SKSpriteNode(imageNamed: targetName)
		target.position = CGPoint(x: 0, y: 255)
		target.zPosition = 25
		target.name = targetName
		addChild(target)

		let move = SKAction.move(by: CGVector(dx: 1200, dy: 0), duration: 4)
		let remove = SKAction.removeFromParent()
		target.run(SKAction.sequence([move, remove]))
	}

	func makeBullsEyeTarget() {
		let targetName = targets[0]
		let target = SKSpriteNode(imageNamed: targetName)
		target.position = CGPoint(x: 1200, y: 420)
		target.zPosition = 15
		target.name = targetName
		addChild(target)

		let stick = SKSpriteNode(imageNamed: "stick0")
		stick.position = CGPoint(x: 1200, y: 310)
		stick.zPosition = 14
		addChild(stick)

		let move = SKAction.move(by: CGVector(dx: -1200, dy: 0), duration: 1.8)
		let remove = SKAction.removeFromParent()
		target.run(SKAction.sequence([move, remove]))
		stick.run(SKAction.sequence([move, remove]))
	}

	func finishGame() {
		gameTimer?.invalidate()
		let gameOver = SKSpriteNode(imageNamed: "game-over")
		gameOver.position = centrePoint
		gameOver.zPosition = 10
		addChild(gameOver)

		timeRemainingLabel?.removeFromParent()
		reloadLabel?.removeFromParent()
	}

	func reload() {
		shotsUsed = 0
		reloadLabel.removeFromParent()
	}
}
