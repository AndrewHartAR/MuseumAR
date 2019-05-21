//
//  ScalingViewNode.swift
//  MuseumARSim
//
//  Created by Andrew Hart on 20/05/2019.
//  Copyright © 2019 Dent Reality. All rights reserved.
//

import UIKit
import SceneKit

class ScalingInterfaceNode: ScaleNode {
	var view: UIView {
		didSet {
			updateView()
		}
	}
	
	private var shape: SCNShape?
	private var interfaceNode = SCNNode()
	
	private var backSideMaterial = SCNMaterial()
	
	init(view: UIView) {
		self.view = view
		
		super.init()
		
		contentNode.addChildNode(interfaceNode)
		
		backSideMaterial.diffuse.intensity = 2.0
		backSideMaterial.metalness.contents = 0
		backSideMaterial.roughness.contents = 0.2
		backSideMaterial.lightingModel = .physicallyBased
		
		updateView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func updateView() {
		let bezierPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: view.layer.cornerRadius)
		bezierPath.flatness = 0.001
		
		shape = SCNShape(path: bezierPath, extrusionDepth: 10)
		shape?.firstMaterial?.diffuse.contents = view
		shape?.insertMaterial(backSideMaterial, at: 1)
		shape?.insertMaterial(backSideMaterial, at: 2)
		
		backSideMaterial.diffuse.contents = view.backgroundColor
		
		interfaceNode.geometry = shape
		
		interfaceNode.position.x = Float(-(bezierPath.bounds.size.width * 0.5))
		interfaceNode.position.y = Float(-(bezierPath.bounds.size.height * 0.5))
	}
}
