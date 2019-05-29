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
		DispatchQueue.main.async {
			let bezierPath = UIBezierPath(roundedRect: self.view.bounds, cornerRadius: self.view.layer.cornerRadius)
			bezierPath.flatness = 0.001
			
			//It's possible to use a view, but that causes lag when it's initially displayed,
			//so we render it to an image instead.
			let image = self.view.image()
			
			self.shape = SCNShape(path: bezierPath, extrusionDepth: 10)
			self.shape?.firstMaterial?.diffuse.contents = image
			self.shape?.insertMaterial(self.backSideMaterial, at: 1)
			self.shape?.insertMaterial(self.backSideMaterial, at: 2)
			
			self.backSideMaterial.diffuse.contents = self.view.backgroundColor
			
			self.interfaceNode.geometry = self.shape
			
			self.interfaceNode.position.x = Float(-(bezierPath.bounds.size.width * 0.5))
			self.interfaceNode.position.y = Float(-(bezierPath.bounds.size.height * 0.5))
		}
	}
}
