//
//  GameScene.swift
//  ShootingGallery
//
//  Created by Paul Richardson on 20/05/2021.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {

	// MARK:- Properties

	var gameTimer: Timer?
	var gameLength = 60
	var timeRemaining: Int!

	var timeRemainingLabel: SKLabelNode!
	var scoreLabel: SKLabelNode!
	var reloadLabel: SKLabelNode!
	var gameOverLabel: SKSpriteNode!
	var newGameLabel: SKLabelNode!

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
				holster2.texture = shots[shotsUsed]
			case 4 ... 5:
				holster1.texture = shots[shotsUsed]
			case 6:
				holster1.texture = shots[shotsUsed]
				addChild(reloadLabel)
			default:
				return
			}
		}
	}

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

	var ducks = [String]()
	var targets = [String]()

	let shots = [
		SKTexture(imageNamed: "shots3"),
		SKTexture(imageNamed: "shots2"),
		SKTexture(imageNamed: "shots1"),
		SKTexture(imageNamed: "shots0"),
		SKTexture(imageNamed: "shots2"),
		SKTexture(imageNamed: "shots1"),
		SKTexture(imageNamed: "shots0"),
	]

	let sticks = ["stick0", "stick1", "stick2"]

	var holster1: SKSpriteNode!
	var holster2: SKSpriteNode!

	let playReload = SKAction.playSoundFileNamed("reload", waitForCompletion: false)
	let playShot = SKAction.playSoundFileNamed("shot", waitForCompletion: false)
	let playEmpty = SKAction.playSoundFileNamed("empty", waitForCompletion: false)

	let centrePoint = CGPoint(x: 512, y: 384)

	// MARK:- Life Cycle

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

		createOverlay(view)

		addGrass()

		addWater()

		startTimer()

	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else { return }
		let location = touch.location(in: self)
		let tappedNodes = nodes(at: location)

		if  timeRemaining > 0 {
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
						node.parent?.run(SKAction.sequence([fade, remove]))
					}
				}
			} else {
				for node in tappedNodes {
					switch node.name {
					case "reload":
						reload()
						return
					default:
						break
					}
				}
				run(playEmpty)
			}
		} else {
			for node in tappedNodes {
				switch node.name {
				case "new":
					newGame()
					return
				default:
					break
				}
			}
		}

	}

	// MARK:- Private Methods

	fileprivate func createOverlay(_ view: SKView) {
		let curtains = SKSpriteNode(imageNamed: "curtains")
		curtains.position = centrePoint
		curtains.blendMode = .alpha
		curtains.scale(to: view.frame.size)
		curtains.zPosition = 90
		addChild(curtains)

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
		scoreLabel.position = CGPoint(x: 120, y: 35)
		scoreLabel.text = "Score: 0"
		scoreLabel.fontSize = 48
		scoreLabel.horizontalAlignmentMode = .left
		scoreLabel.zPosition = 100
		addChild(scoreLabel)

		reloadLabel = SKLabelNode(fontNamed: "Chalkduster")
		reloadLabel.name = "reload"
		reloadLabel.text = "Reload!"
		reloadLabel.fontSize = 48
		reloadLabel.position = CGPoint(x: 874, y: 35)
		reloadLabel.horizontalAlignmentMode = .right
		reloadLabel.zPosition = 100

		newGameLabel = SKLabelNode(fontNamed: "Chalkduster")
		newGameLabel.name = "new"
		newGameLabel.text = "Restart"
		newGameLabel.fontSize = 48
		newGameLabel.position = CGPoint(x: 874, y: 35)
		newGameLabel.horizontalAlignmentMode = .right
		newGameLabel.zPosition = 100

		timeRemainingLabel = SKLabelNode(fontNamed: "SF Mono")
		timeRemainingLabel.color = .green
		timeRemainingLabel.colorBlendFactor = 0.7
		timeRemainingLabel.text = String(timeRemaining)
		timeRemainingLabel.fontSize = 64
		timeRemainingLabel.position = CGPoint(x: 512, y: 700)
		timeRemainingLabel.horizontalAlignmentMode = .center
		timeRemainingLabel.zPosition = 100
		addChild(timeRemainingLabel)

		gameOverLabel = SKSpriteNode(imageNamed: "game-over")
		gameOverLabel.position = centrePoint
		gameOverLabel.zPosition = 100

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

		let tilingCorrection: CGFloat = -5 // images don't tile exactly
		let offset = grass.size.width + tilingCorrection

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

		var positionY: CGFloat = 190
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

		waterBackgroundNode.xScale = 0.85
		waterBackgroundNode.yScale = 0.85
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

		animate(waterForegroundNode, distance: 10, duration: 0.4)
		animate(waterBackgroundNode, distance: 8, duration: 0.6)

	}

	fileprivate func animate(_ node: SKNode, distance: CGFloat, duration: TimeInterval) {
		let moveUp = SKAction.moveBy(x: 0, y: distance, duration: duration)
		let moveDown = moveUp.reversed()
		let sequence = SKAction.sequence([moveUp, moveDown])
		let repeatForever = SKAction.repeatForever(sequence)
		node.run(repeatForever)
	}

	fileprivate func startTimer() {
		gameTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { _ in
			self.makeDuckTarget()
			self.isFullSecond.toggle()
			let x = Int.random(in: 0 ... 6)
			if x == 0 { self.makeBullsEyeTarget() }
		})
	}

	fileprivate func makeDuckTarget() {

		let leftToRight = Bool.random()

		let xPosition:CGFloat = leftToRight ? 0 : 1200
		let yPosition: CGFloat = leftToRight ? 260 : 320
		let zPosition: CGFloat = leftToRight ? 35 : 25
		let moveX: CGFloat = leftToRight ? 1200 : -1200
		let duration: TimeInterval = leftToRight ? 4 : 3

		let targetNode = SKNode()
		addChild(targetNode)

		let targetName = ducks.randomElement()!

		let target = SKSpriteNode(imageNamed: targetName)
		target.xScale = leftToRight ? 1 : -1
		target.position = CGPoint(x: xPosition, y: yPosition)
		target.zPosition = zPosition
		target.name = targetName
		targetNode.addChild(target)

		let stick = SKSpriteNode(imageNamed: sticks.randomElement()!)
		stick.position = CGPoint(x: xPosition, y: yPosition - 110)
		stick.zPosition = zPosition - 1
		targetNode.addChild(stick)

		targetNode.xScale = leftToRight ? 1.0 : 0.85
		targetNode.yScale = leftToRight ? 1.0 : 0.85

		let move = SKAction.move(by: CGVector(dx: moveX, dy: 0), duration: duration)
		let remove = SKAction.removeFromParent()
		targetNode.run(SKAction.sequence([move, remove]))
	}

	fileprivate func makeBullsEyeTarget() {

		let targetNode = SKNode()
		addChild(targetNode)

		let targetName = targets[0]
		let target = SKSpriteNode(imageNamed: targetName)
		target.position = CGPoint(x: 0, y: 390)
		target.zPosition = 15
		target.name = targetName
		targetNode.addChild(target)

		let stick = SKSpriteNode(imageNamed: sticks.randomElement()!)
		stick.position = CGPoint(x: 0, y: 280)
		stick.zPosition = 14
		targetNode.addChild(stick)

		let move = SKAction.move(by: CGVector(dx: 1200, dy: 0), duration: 1.8)
		let remove = SKAction.removeFromParent()
		targetNode.run(SKAction.sequence([move, remove]))
	}

	fileprivate func reload() {
		shotsUsed = 0
		reloadLabel.removeFromParent()
	}

	fileprivate func finishGame() {
		gameTimer?.invalidate()
		gameOverLabel.alpha = 0
		gameOverLabel.run(SKAction.fadeIn(withDuration: 1.0))
		addChild(gameOverLabel)

		timeRemainingLabel?.removeFromParent()
		reloadLabel?.removeFromParent()

		newGameLabel.alpha = 0
		let wait = SKAction.wait(forDuration: 4.0)
		let fadeIn = SKAction.fadeIn(withDuration: 2.0)
		newGameLabel.run(SKAction.sequence([wait, fadeIn]))
		addChild(newGameLabel)
	}

	fileprivate func newGame() {
		newGameLabel.removeFromParent()
		gameOverLabel.removeFromParent()

		score = 0
		shotsUsed = 0

		timeRemaining = gameLength
		timeRemainingLabel.text = String(timeRemaining)
		addChild(timeRemainingLabel)

		startTimer()
	}
}
