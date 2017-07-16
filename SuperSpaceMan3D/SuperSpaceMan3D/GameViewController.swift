//
//  GameViewController.swift
//  SuperSpaceMan3D
//
//  Created by MCUCSIE on 6/26/17.
//  Copyright © 2017 MCUCSIE. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import CoreMotion

class GameViewController: UIViewController, SCNSceneRendererDelegate, SCNPhysicsContactDelegate, GameOverViewDelegate {
    var mainScene: SCNScene!
    var spotLight: SCNNode!
    var motionManager: CMMotionManager!
    var moveDirection: String! = ""
    var gameOverlay: GameOverlay!
    var gameStarted = false

    override func viewDidLoad() {

        start()

        // Set up accelerometer
        setupAccelerometer()

        // Create buttons
        let buttonUp = createButton("up")
        let buttonDown = createButton("down")
        let buttonLeft = createButton("left")
        let buttonRight = createButton("right")

        // Set buttons' constraints
        let upConstraint = setConstraintForButton(button: buttonUp)
        let downConstraint = setConstraintForButton(button: buttonDown)
        let leftConstraint = setConstraintForButton(button: buttonLeft)
        let rightConstraint = setConstraintForButton(button: buttonRight)

        // Add buttons to view
        self.view.addSubview(buttonUp)
        self.view.addSubview(buttonDown)
        self.view.addSubview(buttonLeft)
        self.view.addSubview(buttonRight)

        // Add constraints to view
        self.view.addConstraints(upConstraint)
        self.view.addConstraints(downConstraint)
        self.view.addConstraints(leftConstraint)
        self.view.addConstraints(rightConstraint)
    }

    // MARK: - Button create and setting

    // Coefficients which control uibutton's constraints
    let ButtonWidth: CGFloat = 100
    let ButtonHeight: CGFloat = 50
    let ButtonMultiplier: CGFloat = 1.0
    let ButtonXChange: [String: CGFloat] = ["up": 1, "down": 1, "left": 0, "right": 2]
    let ButtonYChange: [String: CGFloat] = ["up": 2, "down": 0, "left": 1, "right": 1]

    func setConstraintForButton(button: UIButton) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        let buttonXConstraint: NSLayoutConstraint
        let buttonYConstraint: NSLayoutConstraint

        button.translatesAutoresizingMaskIntoConstraints = false

        // Button's height and width constraint
        constraints.append(NSLayoutConstraint(item: button,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: ButtonMultiplier,
                                              constant: ButtonWidth))

        constraints.append(NSLayoutConstraint(item: button,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: ButtonMultiplier,
                                              constant: ButtonHeight))

        // Button's x and y constraint
        let buttonTitle = button.titleLabel!.text!
        let XChange = ButtonXChange[buttonTitle]!
        let YChange = ButtonYChange[buttonTitle]!

        buttonXConstraint = NSLayoutConstraint(item: button,
                                               attribute: .left,
                                               relatedBy: .equal,
                                               toItem: self.view,
                                               attribute: .left,
                                               multiplier: ButtonMultiplier,
                                               constant: XChange * ButtonWidth)

        buttonYConstraint = NSLayoutConstraint(item: button,
                                               attribute: .bottom,
                                               relatedBy: .equal,
                                               toItem: self.view,
                                               attribute: .bottom,
                                               multiplier: ButtonMultiplier,
                                               constant: -YChange * ButtonHeight)

        constraints.append(buttonXConstraint)
        constraints.append(buttonYConstraint)

        return constraints

    }

    func createButton(_ title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(touchDownAction), for: .touchDown)
        button.addTarget(self, action: #selector(touchUpAction), for: .touchUpInside)
        button.backgroundColor = UIColor.white
        button.setTitleColor(.black, for: .normal)

        return button
    }

    func touchDownAction(_ sender: UIButton) {

        if !gameStarted {
            gameOverlay.startTimer()
            gameStarted = true
        }

        moveDirection = sender.titleLabel?.text

        moveSpaceman(moveDirection)
    }

    func touchUpAction(_ sender: UIButton) {
        moveDirection = ""
    }

    // MARK: - Environment methods
    func createMainScene() -> SCNScene {

        // Create scene from dae file
        let mainScene = SCNScene(named: "art.scnassets/hero.dae")

        // Add Floor and obstacles
        mainScene?.rootNode.addChildNode(createFloorNode())
        mainScene?.rootNode.addChildNode(Collectable.pyramidNode())
        mainScene?.rootNode.addChildNode(Collectable.sphereNode())
        mainScene?.rootNode.addChildNode(Collectable.boxNode())
        mainScene?.rootNode.addChildNode(Collectable.tubeNode())
        mainScene?.rootNode.addChildNode(Collectable.cylinderNode())
        mainScene?.rootNode.addChildNode(Collectable.torusNode())

        // Set up spot light
        setupLighting(scene: mainScene!)

        // Set up hero's collision detection
        let heroNode = mainScene?.rootNode.childNode(withName: "hero", recursively: true)
        heroNode?.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)

        // Set GameViewController to be delegate for reacting collision
        mainScene?.physicsWorld.contactDelegate = self

        return mainScene!
    }

    func createFloorNode() -> SCNNode {

        // Create floor node
        let floorNode = SCNNode()
        floorNode.geometry = SCNFloor()
        floorNode.geometry?.firstMaterial?.diffuse.contents = "Floor"
        floorNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)

        return floorNode
    }

    func createHeroCamera() {

        // Create main camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.name = "mainCamera"
//        cameraNode.position = SCNVector3Make(0, 10, -50)
//        cameraNode.rotation = SCNVector4Make(0, 1, 0, Float.pi)
        cameraNode.camera?.zFar = 500
        cameraNode.position = SCNVector3Make(0, 50, -100)
        cameraNode.rotation = SCNVector4Make(0, 1, 0.3, Float.pi)

        let heroNode = mainScene.rootNode.childNode(withName: "hero", recursively: true)
        heroNode?.addChildNode(cameraNode)
    }

    func setupLighting(scene: SCNScene) {

        // Set up spot light
        let heroNode = scene.rootNode.childNode(withName: "hero", recursively: true)

        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.white
        heroNode?.addChildNode(ambientLightNode)

        let spotLightNode = SCNNode()
        spotLightNode.light = SCNLight()
        spotLightNode.light?.type = .spot
        spotLightNode.light?.castsShadow = true
        spotLightNode.light?.color = UIColor(white: 0.8, alpha: 1.0)
        spotLightNode.position = SCNVector3Make(0, 80, 30)
        spotLightNode.rotation = SCNVector4Make(1, 0, 0, Float(-.pi/2.8))
        spotLightNode.light?.spotOuterAngle = 50
        spotLightNode.light?.shadowColor = UIColor.black
        spotLightNode.light?.zFar = 500
        spotLightNode.light?.zNear = 50
        heroNode?.addChildNode(spotLightNode)
    }

    func setupAccelerometer() {
        // Create the motion manager to receive the input
        motionManager = CMMotionManager()
        if  motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 1
            motionManager.startAccelerometerUpdates(to: OperationQueue()) { (data, error) in

                let threshold = 0.20

                // Moving right or left
                if (data?.acceleration.y)! < -threshold {
                    self.moveSpaceman("right")
                }
                else if (data?.acceleration.y)! > threshold {
                    self.moveSpaceman("left")
                }

                // Moving up or down
                if (data?.acceleration.x)! < -threshold {
                    self.moveSpaceman("up")
                }
                else if (data?.acceleration.x)! > threshold {
                    self.moveSpaceman("down")
                }
            }
        }
    }

    func moveSpaceman(_ direction: String) {

        // Move hero according accelerometer
        let moveSpeed = TimeInterval(1.0)
        let moveDistance = Float(10.0)
        let heroNode = mainScene.rootNode.childNode(withName: "hero", recursively: true)

        let currentX = heroNode?.position.x
        let currentY = heroNode?.position.y
        let currentZ = heroNode?.position.z

        var action: SCNAction!
        switch direction {
            case "right":
                action = SCNAction.move(to: SCNVector3(currentX! - moveDistance, currentY!, currentZ!),
                                        duration: moveSpeed)

            case "left":
                action = SCNAction.move(to: SCNVector3(currentX! + moveDistance, currentY!, currentZ!),
                                        duration: moveSpeed)

            case "up":
                action = SCNAction.move(to: SCNVector3(currentX!, currentY!, currentZ! + moveDistance),
                                       duration: moveSpeed)

            case "down":
                action = SCNAction.move(to: SCNVector3(currentX!, currentY!, currentZ! - moveDistance),
                                        duration: moveSpeed)

            default:
                break
        }
        heroNode?.runAction(action)
    }

    func start() {
        gameStarted = false

        // Create a scene
        mainScene = createMainScene()

        // Create a camera and attach to hero
        createHeroCamera()

        // Set scene to view
        let sceneView = self.view as! SCNView
        sceneView.delegate = self
        sceneView.scene = mainScene
        sceneView.overlaySKScene = GameOverlay(size: view.frame.size)
        gameOverlay = sceneView.overlaySKScene as! GameOverlay
    }

    // MARK: - SCNPhysicsContactDelegate methods

    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        var contactNode: SCNNode!

        if contact.nodeA.physicsBody?.categoryBitMask == CollisionCategoryHero {
            contactNode = contact.nodeB
        }
        else {
            contactNode = contact.nodeA
        }

        switch contactNode.physicsBody!.categoryBitMask {
            case CollisionCategoryCollectibleLowValue:
                gameOverlay.score = gameOverlay.score + 10

            case CollisionCategoryCollectibleMidValue:
                gameOverlay.score = gameOverlay.score + 20

            case CollisionCategoryCollectibleHighValue:
                gameOverlay.score = gameOverlay.score + 30

            default:
                print("Hit something other than a collectible.")
        }

        contactNode.removeFromParentNode()

        if gameOverlay.score >= 30 {
            gameOverlay.stopTimer()
            gameStarted = false

            let gameOverView = GameOverView(size: self.view.frame.size, score: gameOverlay.scoreNode.text!)
            gameOverView.gameOverViewDelegate = self

            (self.view as! SCNView).overlaySKScene = gameOverView
        }
    }

    // MARK: - SCNSceneRendererDelegate methods

    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        if moveDirection != "" {
            moveSpaceman(moveDirection)
        }
    }

    // MARK: - GameOverDelegate methods

    func gameOverViewTouchBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        start()
    }
}
