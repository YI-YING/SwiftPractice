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

class GameViewController: UIViewController, SCNSceneRendererDelegate, SCNPhysicsContactDelegate {
    var mainScene: SCNScene!
    var spotLight: SCNNode!
    var touchCount: Int?
    var motionManager: CMMotionManager!
    var moveDirection: String! = ""

    override func viewDidLoad() {

        // Create a scene
        mainScene = createMainScene()

        // Create a camera and attach to hero
        createHeroCamera()

        // Set scene to view
        let sceneView = self.view as! SCNView
        sceneView.delegate = self
        sceneView.scene = mainScene

        // Set up accelerometer
        setupAccelerometer()

        let buttonUp = createButton("up",
                                    x: 100,
                                    y: 250,
                                    width: 100,
                                    height: 50)

        let buttonDown = createButton("down",
                                      x: 100,
                                      y: 350,
                                      width: 100,
                                      height: 50)

        let buttonLeft = createButton("left",
                                      x: 0,
                                      y: 300,
                                      width: 100,
                                      height: 50)

        let buttonRight = createButton("right",
                                       x: 200,
                                       y: 300,
                                       width: 100,
                                       height: 50)

        self.view.addSubview(buttonUp)
        self.view.addSubview(buttonDown)
        self.view.addSubview(buttonLeft)
        self.view.addSubview(buttonRight)


    }

    func createButton(_ title: String, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> UIButton {
        let button = UIButton(frame: CGRect(x: x, y: y, width: width, height: height))
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(touchDownAction), for: .touchDown)
        button.addTarget(self, action: #selector(touchUpAction), for: .touchUpInside)
        button.backgroundColor = UIColor.white
        button.setTitleColor(.black, for: .normal)

        return button
    }

    func touchDownAction(_ sender: UIButton) {

        moveDirection = sender.titleLabel?.text

        moveSpaceman(moveDirection)
    }

    func touchUpAction(_ sender: UIButton) {
        moveDirection = ""
    }


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
                print("Hit a low value " + contactNode.name!)

            case CollisionCategoryCollectibleMidValue:
                print("Hit a mid value " + contactNode.name!)

            case CollisionCategoryCollectibleHighValue:
                print("Hit a high value " + contactNode.name!)

            default:
                print("Hit something other than a collectible.")
        }
    }

    // MARK: - SCNSceneRendererDelegate methods

    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        if moveDirection != "" {
            moveSpaceman(moveDirection)
        }
    }
}
