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

class GameViewController: UIViewController, SCNSceneRendererDelegate {
    var mainScene: SCNScene!
    var spotLight: SCNNode!
    var touchCount: Int?
    var motionManager: CMMotionManager!

    override func viewDidLoad() {
        mainScene = createMainScene()
        createHeroCamera()

        let sceneView = self.view as! SCNView
        sceneView.scene = mainScene

        setupAccelerometer()

    }

    func createMainScene() -> SCNScene {
        let mainScene = SCNScene(named: "art.scnassets/hero.dae")
        mainScene?.rootNode.addChildNode(createFloorNode())
        mainScene?.rootNode.addChildNode(Collectable.pyramidNode())
        mainScene?.rootNode.addChildNode(Collectable.sphereNode())
        mainScene?.rootNode.addChildNode(Collectable.boxNode())
        mainScene?.rootNode.addChildNode(Collectable.tubeNode())
        mainScene?.rootNode.addChildNode(Collectable.cylinderNode())
        mainScene?.rootNode.addChildNode(Collectable.torusNode())
        setupLighting(scene: mainScene!)

        return mainScene!
    }

    func createFloorNode() -> SCNNode {
        let floorNode = SCNNode()
        floorNode.geometry = SCNFloor()
        floorNode.geometry?.firstMaterial?.diffuse.contents = "Floor"

        return floorNode
    }

    func createHeroCamera() {
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
}
