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
	
	private var pulseTimer: Timer!
	
	override init() {
		centralCylinder = SCNCylinder(radius: 4, height: 1)
		centralCylinder.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.8)
		centralCylinderNode = SCNNode(geometry: centralCylinder)
		
		ringTube = SCNTube(innerRadius: 8, outerRadius: 9, height: 1)
		ringTube.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.8)
		ringTubeNode = SCNNode(geometry: ringTube)
		
		super.init()
		
		beaconContainerNode.addChildNode(centralCylinderNode)
		beaconContainerNode.addChildNode(ringTubeNode)
		
		beaconContainerNode.eulerAngles.x = Float(90).degreesToRadians
		addChildNode(beaconContainerNode)
		
		DispatchQueue.main.async {
			self.pulseTimer = Timer.scheduledTimer(
				timeInterval: 1.5,
				target: self,
				selector: #selector(self.pulse),
				userInfo: nil,
				repeats: true)
			self.pulseTimer.fire()
		}
	}
	
	@objc private func pulse() {
		let pulseTube = SCNTube(innerRadius: 8, outerRadius: 8.5, height: 1)
		pulseTube.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.8)
		let pulseTubeNode = SCNNode(geometry: pulseTube)
		
		beaconContainerNode.addChildNode(pulseTubeNode)
		
		CATransaction.begin()
		let animation = CABasicAnimation(keyPath: "outerRadius")
		animation.duration = 3
		animation.toValue = 54
		pulseTube.addAnimation(animation, forKey: nil)
		
		let innerRadiusAnimation = CABasicAnimation(keyPath: "innerRadius")
		innerRadiusAnimation.duration = 3
		innerRadiusAnimation.toValue = 52
		pulseTube.addAnimation(innerRadiusAnimation, forKey: nil)
		CATransaction.commit()
		
		let fadeAction = SCNAction.fadeOut(duration: 2)
		pulseTubeNode.runAction(fadeAction) {
			pulseTubeNode.removeFromParentNode()
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
