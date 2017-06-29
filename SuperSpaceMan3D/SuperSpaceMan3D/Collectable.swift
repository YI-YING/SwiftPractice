//
//  Collectable.swift
//  SuperSpaceMan3D
//
//  Created by MCUCSIE on 6/27/17.
//  Copyright © 2017 MCUCSIE. All rights reserved.
//

import Foundation
import SceneKit

class Collectable {
    class func pyramidNode() -> SCNNode {
        let pyramid = SCNPyramid(width: 3.0, height: 6.0, length: 3.0)
        let pyramidNode = SCNNode(geometry: pyramid)
        pyramidNode.name = "pyramid"

        let position = SCNVector3Make(0, 0, 20)
        pyramidNode.position = position
        pyramidNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue

        return pyramidNode
    }

    class func sphereNode() -> SCNNode {
        let sphere = SCNSphere(radius: 6.0)
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.name = "sphere"

        let position = SCNVector3Make(0, 6, -20)
        sphereNode.position = position
        sphereNode.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "earthDiffuse")
        sphereNode.geometry?.firstMaterial?.ambient.contents = #imageLiteral(resourceName: "earthAmbient")
        sphereNode.geometry?.firstMaterial?.specular.contents = #imageLiteral(resourceName: "earthSpecular")
        sphereNode.geometry?.firstMaterial?.normal.contents = #imageLiteral(resourceName: "earthNormal")

        return sphereNode
    }

    class func boxNode() -> SCNNode {
        let box = SCNBox(width: 3, height: 3, length: 3, chamferRadius: 0)

        let boxNode = SCNNode(geometry: box)
        boxNode.name = "box"

        let position = SCNVector3Make(20, 3.0, 0)
        boxNode.position = position

        var materials = [SCNMaterial]()
        let boxImage = "boxSide"

        for index in 1...6 {
            let material = SCNMaterial()
            material.diffuse.contents = UIImage(named: boxImage + String(index))
            materials.append(material)
        }
        boxNode.geometry?.materials = materials

        return boxNode
    }

    class func tubeNode() -> SCNNode {
        let tube = SCNTube(innerRadius: 1, outerRadius: 1.5, height: 2.0)
        let tubeNode = SCNNode(geometry: tube)
        tubeNode.name = "tube"

        let position = SCNVector3Make(-20, 1.5, 0)
        tubeNode.position = position
        tubeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.green

        return tubeNode
    }

    class func cylinderNode() -> SCNNode {
        let cylinder = SCNCylinder(radius: 3, height: 8)
        let cylinderNode = SCNNode(geometry: cylinder)
        cylinderNode.name = "cylindernode"

        let position = SCNVector3Make(30, 8, 30)
        cylinderNode.position = position
        cylinderNode.geometry?.firstMaterial?.diffuse.contents = UIColor.black
        cylinderNode.geometry?.firstMaterial?.shininess = 0.5

        return cylinderNode
    }

    class func torusNode() -> SCNNode {
        let torus = SCNTorus(ringRadius: 7, pipeRadius: 2)
        let torusNode = SCNNode(geometry: torus)
        torusNode.name = "torus"

        let position = SCNVector3Make(-30, 0, 30)
        torusNode.position = position
        torusNode.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow

        return torusNode
    }
}
