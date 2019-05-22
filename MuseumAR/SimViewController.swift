//
//  ViewController.swift
//  MuseumAR
//
//  Created by Andrew Hart on 13/05/2019.
//  Copyright © 2019 Dent Reality. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class BillboardInterfaceNode: ScalingInterfaceNode, BillboardableNode {
	var directions: [BillboardDirection] = [.vertical]
	
	var billboardContentNode = SCNNode()
	
	override init(view: UIView) {
		super.init(view: view)
		
		billboardContentNode = contentNode
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

class Beacon {
	var node: BeaconNode
	var contentTitle: String
	var contentSummary: String
	
	init(node: BeaconNode, contentTitle: String, contentSummary: String) {
		self.node = node
		self.contentTitle = contentTitle
		self.contentSummary = contentSummary
	}
}

struct BeaconFocus {
	var beacon: Beacon
	var focusDate = Date()
}

class SimViewController: UIViewController, ARSCNViewDelegate {
    let sceneView = ARSCNView()
	
	let artworkNode = SCNNode()
	
	let beacon1Node = BeaconNode()
	
	var beacons = [Beacon]()
	
	weak var activeBeacon: Beacon? {
		didSet {
			if oldValue?.node != activeBeacon?.node {
				DispatchQueue.main.async {
					if self.activeBeacon != nil {
						self.animateInMaskView()
					} else {
						self.animateOutMaskView()
					}
				}
				
				oldValue?.node.mode = .normal
				activeBeacon?.node.mode = .hidden
				
				DispatchQueue.main.async {
					self.detailView.title = self.activeBeacon?.contentTitle
					self.detailView.summary = self.activeBeacon?.contentSummary
					self.detailView.setNeedsLayout()
					
					self.detailView.isHidden = self.activeBeacon == nil
				}
			}
		}
	}
	
	var beaconFocus: BeaconFocus? {
		didSet {
			if oldValue?.beacon.node != beaconFocus?.beacon.node {
				if oldValue?.beacon.node != activeBeacon?.node {
					oldValue?.beacon.node.mode = .normal
				}
				
				beaconFocus?.beacon.node.mode = .focus
			}
		}
	}
	
	//Allows us to reference the frame while not on the main thread
	private var cachedBounds = CGRect.zero
	
	let titleView = UIView()
	var titleNode: BillboardInterfaceNode!
	
	let maskView = UIView()
	let maskViewCutoutView = UIView()
	let maskViewCutoutOutline = UIView()
	
	private static let titleLabelInset: CGFloat = 8
	private static let titleLabelSubtitleDifference: CGFloat = 4
	
	private static let cutoutRadius: CGFloat = 80
	
	private static let focusRadius: CGFloat = 40
	private static let focusDuration: Double = 0.8
	
	private let dotView = UIView()
	
	private let detailView = DetailView()
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		view.backgroundColor = UIColor.black
        
        sceneView.delegate = self
		view.addSubview(sceneView)
		
		let image = UIImage(named: "testStudio.jpg")
		sceneView.scene.lightingEnvironment.contents = image
		
		let paintingImage = UIImage(named: "image1")!
		
//		let simBackgroundImage = SimBackgroundImage(
//			image: UIImage(named: "image1")!,
//			horizontalSpan: Float(60).degreesToRadians)
//		let skyboxImage = simBackgroundImage.skyboxImage()
		
//		sceneView.scene.background.contents = skyboxImage
		
		//Rather than using SimBackgroundImage (for panoramas), we'll use a plane,
		//since our image is flat, rather than a panorama
		//This also allows us to interact with it in 6DOF
		sceneView.scene.background.contents = UIColor.black
		
		maskView.backgroundColor = UIColor(white: 0, alpha: 1)
		
		dotView.frame.size = CGSize(width: 4, height: 4)
		dotView.layer.cornerRadius = 2
		dotView.backgroundColor = UIColor.white
		self.dotView.alpha = SimViewController.dotViewStandardAlpha
		sceneView.addSubview(dotView)
		
		maskViewCutoutView.backgroundColor = UIColor.white
		maskViewCutoutView.frame.size = CGSize(
			width: SimViewController.cutoutRadius * 2,
			height: SimViewController.cutoutRadius * 2)
		maskViewCutoutView.layer.cornerRadius = SimViewController.cutoutRadius
		maskView.addSubview(maskViewCutoutView)
		sceneView.mask = maskView
		
		maskViewCutoutOutline.frame.size = maskViewCutoutView.frame.size
		maskViewCutoutOutline.layer.cornerRadius = maskViewCutoutView.layer.cornerRadius
		maskViewCutoutOutline.layer.borderWidth = 2
		maskViewCutoutOutline.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
		maskViewCutoutOutline.isHidden = true
		sceneView.addSubview(maskViewCutoutOutline)
		
		detailView.isHidden = true
		view.addSubview(detailView)
		
		let plane = SCNPlane(width: 3.367, height: 2.509)
		plane.firstMaterial?.diffuse.contents = paintingImage
		
		let planeNode = SCNNode(geometry: plane)
		planeNode.position.z = -2
		sceneView.scene.rootNode.addChildNode(planeNode)
		
		let artworkPlane = SCNPlane(width: 2.15, height: 1.13)
		artworkPlane.firstMaterial?.diffuse.contents = UIColor.clear
		artworkNode.geometry = artworkPlane
		artworkNode.position.z = 0.01
		planeNode.addChildNode(artworkNode)
		
		beacon1Node.position.z = 0.01
		beacon1Node.position.x = -0.266
		beacon1Node.position.y = 0.112
		artworkNode.addChildNode(beacon1Node)
		
		let beacon1 = Beacon(node: beacon1Node, contentTitle: "Heading", contentSummary: "This is some content which I expect will extend for several lines as I attempt to explain my position on what this content is really about.")
		beacons.append(beacon1)
		
		let label = UILabel()
		label.text = "French Fire Rafts Attacking the English Fleet off Quebec"
		label.font = UIFont.boldSystemFont(ofSize: 18)
		label.textAlignment = .center
		label.textColor = UIColor.black
		label.backgroundColor = UIColor.clear
		label.numberOfLines = 0
		label.frame.size = label.sizeThatFits(CGSize(width: 280, height: CGFloat.greatestFiniteMagnitude))
		
		let subheadingLabel = UILabel()
		subheadingLabel.text = "28 June 1759, Samuel Scott"
		subheadingLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
		subheadingLabel.textAlignment = .center
		subheadingLabel.textColor = UIColor(white: 0.35, alpha: 1.0)
		subheadingLabel.backgroundColor = UIColor.clear
		subheadingLabel.numberOfLines = 1
		subheadingLabel.sizeToFit()
		
		titleView.addSubview(label)
		titleView.addSubview(subheadingLabel)
		titleView.frame.size = CGSize(
			width: label.frame.size.width + (SimViewController.titleLabelInset * 2),
			height: label.frame.size.height + SimViewController.titleLabelSubtitleDifference +
				subheadingLabel.frame.size.height + (SimViewController.titleLabelInset * 2))
		titleView.backgroundColor = UIColor.white
		titleView.layer.cornerRadius = 18
		label.center.x = titleView.frame.size.width / 2
		label.frame.origin.y = SimViewController.titleLabelInset
		subheadingLabel.center.x = titleView.frame.size.width / 2
		subheadingLabel.frame.origin.y = label.frame.origin.y + label.frame.size.height +
			SimViewController.titleLabelSubtitleDifference
		
		titleNode = BillboardInterfaceNode(view: titleView)
		titleNode.position.z = 0.05
		titleNode.position.y = Float(-(artworkPlane.height * 0.5))
		titleNode.opacity = 0.8
		artworkNode.addChildNode(titleNode)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		sceneView.frame = view.bounds
		maskView.frame.size = sceneView.bounds.size
		dotView.center = focusPoint
		detailView.frame = view.bounds
		
		cachedBounds = sceneView.bounds
	}
	
	var focusPoint: CGPoint {
		return CGPoint(
			x: sceneView.bounds.size.width / 2,
			y: sceneView.bounds.size.height - (sceneView.bounds.size.height / 1.618))
	}
	
	func animateInMaskView() {
		UIView.animate(withDuration: 0.4) {
			self.maskView.backgroundColor = UIColor(white: 0, alpha: 0.65)
			self.dotView.alpha = 0
		}
		
		self.maskViewCutoutView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
		self.maskViewCutoutOutline.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
		self.maskViewCutoutOutline.isHidden = false
		
		UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseOut, animations: {
			self.maskViewCutoutView.transform = CGAffineTransform(scaleX: 1, y: 1)
			self.maskViewCutoutOutline.transform = CGAffineTransform(scaleX: 1, y: 1)
		}, completion: nil)
	}
	
	static let dotViewStandardAlpha: CGFloat = 0.8
	
	func animateOutMaskView() {
		UIView.animate(withDuration: 0.2) {
			self.maskView.backgroundColor = UIColor(white: 0, alpha: 1)
			self.dotView.alpha = SimViewController.dotViewStandardAlpha
		}
		
		UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
			self.maskViewCutoutView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
			self.maskViewCutoutOutline.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
		}) { _ in
			self.maskViewCutoutView.transform = CGAffineTransform(scaleX: 1, y: 1)
			self.maskViewCutoutOutline.transform = CGAffineTransform(scaleX: 1, y: 1)
			self.maskViewCutoutOutline.isHidden = true
		}
	}

    // MARK: - ARSCNViewDelegate
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
	
	func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
		guard let currentFrame = sceneView.session.currentFrame,
		let pov = sceneView.pointOfView else {
			return
		}
		
		let imageResolution = currentFrame.camera.imageResolution
		let intrinsics = currentFrame.camera.intrinsics
//		let xFOV = 2 * atan(Float(imageResolution.width)/(2 * intrinsics[0,0]))
		var yFOV = 2 * atan(Float(imageResolution.height)/(2 * intrinsics[1,1]))
		
		let visibleYFOVScale = min(
			1,
			(cachedBounds.size.width / cachedBounds.size.height) /
				(imageResolution.height / imageResolution.width))
		
		yFOV *= Float(visibleYFOVScale)
		
		let A = yFOV * 0.5
		let B = Float(180).degreesToRadians - A - Float(90).degreesToRadians
		let a = (sin(A) * 1) / sin(B)
		
		//Visible distance, at a distance from the camera of 1m
		let horizontalVisibleDistance = a * 2
		
		let horizontalDistancePerPoint = horizontalVisibleDistance / Float(cachedBounds.size.width)
		
		let childNodes = self.sceneView.scene.rootNode.recursiveChildNodes()
		let scaleNodes = childNodes.filter({$0 is ScaleNode}) as! [ScaleNode]
		
		DispatchQueue.main.async {
			let focusPoint = self.focusPoint
			
			if let activeBeacon = self.activeBeacon {
				let beaconPosition = self.beacon1Node.convertPosition(SCNVector3Zero, to: nil)
				
				let projectedPoint = renderer.projectPoint(beaconPosition)
				let projectedCGPoint = CGPoint(x: CGFloat(projectedPoint.x), y: CGFloat(projectedPoint.y))
				
				self.maskViewCutoutView.center = projectedCGPoint
				self.maskViewCutoutOutline.center = projectedCGPoint
			} else {
				for beacon in self.beacons {
					let beaconPosition = beacon.node.convertPosition(SCNVector3Zero, to: nil)
					let projectedPoint = renderer.projectPoint(beaconPosition)
					let projectedCGPoint = CGPoint(x: CGFloat(projectedPoint.x), y: CGFloat(projectedPoint.y))
					let distance = projectedCGPoint.distance(to: focusPoint)
					
					if distance < SimViewController.focusRadius {
						if let beaconFocus = self.beaconFocus {
							if beaconFocus.beacon.node == beacon.node,
								Date().timeIntervalSince(beaconFocus.focusDate) > SimViewController.focusDuration {
								self.activeBeacon = beacon
								self.beaconFocus = nil
							}
						} else {
							self.beaconFocus = BeaconFocus(beacon: beacon, focusDate: Date())
						}
					} else {
						if let beaconFocus = self.beaconFocus,
							beaconFocus.beacon.node == beacon.node {
							self.beaconFocus = nil
						}
					}
				}
			}
		}
		
		for scaleNode in scaleNodes {
			let relativeNodePosition = self.sceneView.scene.rootNode.convertPosition(pov.position, to: scaleNode)
			
			let distanceFromNode = SCNVector3Zero.distance(to: relativeNodePosition)
			
			let scale = horizontalDistancePerPoint * distanceFromNode
			
			scaleNode.contentNode.scale = SCNVector3(scale, scale, scale)
		}
		
		let billboardNodes = childNodes.filter({$0 is BillboardableNode}) as! [BillboardableNode]
		
		for billboardNode in billboardNodes {
			let relativeNodePosition = self.sceneView.scene.rootNode.convertPosition(pov.position, to: billboardNode)
			
			let headingFromNode = SCNVector3Zero.heading(to: relativeNodePosition)
			
			if billboardNode.directions.contains(.horizontal) {
				billboardNode.billboardContentNode.eulerAngles.y = Float(180).degreesToRadians - headingFromNode.horizontal
			}
			
			if billboardNode.directions.contains(.vertical) {
				billboardNode.billboardContentNode.eulerAngles.x = -headingFromNode.vertical
			}
		}
	}
}
