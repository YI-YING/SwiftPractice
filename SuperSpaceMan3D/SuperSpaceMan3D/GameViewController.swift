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

    override func viewDidLoad() {

        // Create a scene
        mainScene = createMainScene()

        // Create a camera and attach to hero
        createHeroCamera()

        // Set scene to view
        let sceneView = self.view as! SCNView
        sceneView.scene = mainScene

        // Set up accelerometer
        setupAccelerometer()

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
        heroNode?.physicsBody?.categoryBitMask = CollisionCategoryHero
        heroNode?.physicsBody?.collisionBitMask = CollisionCategoryCollectibleLowValue | CollisionCategoryCollectibleMidValue | CollisionCategoryCollectibleHighValue

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
        SCNTransaction.animationDuration = 3
        let moveDistance = Float(10.0)
        let heroNode = mainScene.rootNode.childNode(withName: "hero", recursively: true)

        let currentX = heroNode?.position.x
        let currentY = heroNode?.position.y
        let currentZ = heroNode?.position.z

        switch direction {
            case "right":
                heroNode?.position = SCNVector3(currentX! + moveDistance, currentY!, currentZ!)

            case "left":
                heroNode?.position = SCNVector3(currentX! - moveDistance, currentY!, currentZ!)

            case "up":
                heroNode?.position = SCNVector3(currentX!, currentY!, currentZ! - moveDistance)

            case "down":
                heroNode?.position = SCNVector3(currentX!, currentY!, currentZ! + moveDistance)

            default:
                break
        }
    }

    // MARK: - SCNPhysicsContactDelegate methods

    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        switch contact.nodeB.physicsBody!.collisionBitMask {
        case CollisionCategoryCollectibleLowValue:
            print("Hit a low value collectible.")

        case CollisionCategoryCollectibleMidValue:
            print("Hit a mid value collectible.")

        case CollisionCategoryCollectibleHighValue:
            print("Hit a high value collectible.")
        default:
            print("Hit something other than a collectible.")
        }
    }

    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        print("didEndContact")
    }

    func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) {
        print("didUpdateContact")
    }
}
