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
	enum Mode {
		case normal
		case focus
		case hidden
	}
	
	var mode = Mode.normal {
		didSet {
			if oldValue != mode {
				if mode == .focus {
					animateToAttention()
				} else if mode == .normal {
					animateIn(completion: nil)
				} else if mode == .hidden {
					animateOut(completion: nil)
				}
			}
		}
	}
	
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
		contentNode.addChildNode(beaconContainerNode)
		
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
		if mode != .normal {
			return
		}
		
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
		
		let fadeAction = SCNAction.fadeOut(duration: 1.5)
		pulseTubeNode.runAction(fadeAction) {
			pulseTubeNode.removeFromParentNode()
		}
	}
	
	func animateIn(completion: (() -> Void)?) {
		opacity = 0
		
		let fadeAction = SCNAction.fadeIn(duration: 0.4)
		runAction(fadeAction)
		
		centralCylinderNode.scale = SCNVector3(0.01, 0.01, 0.01)
		let scaleCylinderAction = SCNAction.scale(to: 1, duration: 0.15)
		centralCylinderNode.runAction(scaleCylinderAction)
		
		ringTubeNode.scale = SCNVector3(0.01, 0.01, 0.01)
		let scaleTubeAction = SCNAction.scale(to: 1, duration: 0.4)
		ringTubeNode.runAction(scaleTubeAction) {
			completion?()
		}
	}
	
	func animateToAttention() {
		let scaleTubeAction = SCNAction.scale(to: 1.6, duration: 0.2)
		ringTubeNode.runAction(scaleTubeAction)
	}
	
	func animateOut(completion: (() -> Void)?) {
		let fadeAction = SCNAction.fadeOut(duration: 1)
		self.runAction(fadeAction) {
			completion?()
		}
		
		let scaleTubeAction = SCNAction.scale(to: 0.01, duration: 0.2)
		ringTubeNode.runAction(scaleTubeAction)
		
		let waitAction = SCNAction.wait(duration: 0.01)
		self.centralCylinderNode.runAction(waitAction) {
			let scaleCylinderAction = SCNAction.scale(to: 0.015, duration: 0.05)
			self.centralCylinderNode.runAction(scaleCylinderAction)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
