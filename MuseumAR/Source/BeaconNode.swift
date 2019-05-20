//
//  BeaconNode.swift
//  MuseumARSim
//
//  Created by Andrew Hart on 20/05/2019.
//  Copyright © 2019 Dent Reality. All rights reserved.
//

import Foundation
import SceneKit

class BeaconNode: ScaleNode {
	private let centralCylinder: SCNCylinder
	private let centralCylinderNode: SCNNode
	
	private let ringTube: SCNTube
	private let ringTubeNode: SCNNode
	
	private let beaconContainerNode = SCNNode()
	
	override init() {
		centralCylinder = SCNCylinder(radius: 5, height: 1)
		centralCylinder.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.8)
		centralCylinderNode = SCNNode(geometry: centralCylinder)
		
		ringTube = SCNTube(innerRadius: 10, outerRadius: 11.5, height: 1)
		ringTube.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.8)
		ringTubeNode = SCNNode(geometry: ringTube)
		
		super.init()
		
		beaconContainerNode.addChildNode(centralCylinderNode)
		beaconContainerNode.addChildNode(ringTubeNode)
		
		beaconContainerNode.eulerAngles.x = Float(90).degreesToRadians
		addChildNode(beaconContainerNode)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
