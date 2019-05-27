//
//  ARArtView.swift
//  MuseumARSim
//
//  Created by Andrew Hart on 23/05/2019.
//  Copyright © 2019 Dent Reality. All rights reserved.
//

import UIKit
import ARKit

protocol ARArtViewDelegate: class {
	func artworkForDetectedImage(artView: ARArtView, image: ARReferenceImage) -> Artwork?
}

class ARArtView: UIView {
	let sceneView = ARSCNView()
	
	var sceneArtwork: SceneArtwork? {
		didSet {
			oldValue?.node.removeFromParentNode()
			sceneBeacons.removeAll()
			
			activeBeacon = nil
			beaconFocus = nil
			
			setupArtwork()
		}
	}
	
	private var sceneBeacons = [SceneBeacon]()
	
	private weak var activeBeacon: SceneBeacon? {
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
					self.detailView.title = self.activeBeacon?.beacon.contentTitle
					self.detailView.summary = self.activeBeacon?.beacon.contentSummary
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
	
	weak var delegate: ARArtViewDelegate?
	
	//Allows us to reference the frame while not on the main thread
	private var cachedBounds = CGRect.zero
	
	var titleNode: BillboardInterfaceNode!
	
	let maskViewCutoutView = UIView()
	let maskViewCutoutOutline = UIView()
	
	private static let titleLabelInset: CGFloat = 8
	private static let titleLabelSubtitleDifference: CGFloat = 4
	
	private static let cutoutRadius: CGFloat = 80
	
	private static let focusRadius: CGFloat = 40
	private static let focusDuration: Double = 0.8
	private static let titleNodeStandardAlpha: Float = 0.8
	private static let dotViewStandardAlpha: CGFloat = 0.8
	
	private let dotView = UIView()
	
	private let detailView = DetailView()
	
	private let phantomAnchorNode = SCNNode()
	private let phantomNode = PhantomArtworkNode()
	
	var focusPoint: CGPoint {
		return CGPoint(
			x: sceneView.bounds.size.width / 2,
			y: sceneView.bounds.size.height - (sceneView.bounds.size.height / 1.618))
	}
	
	var isDisplayingPhantomArtwork = false
	
	init() {
		super.init(frame: CGRect.zero)
		
		backgroundColor = UIColor.black
		
		sceneView.delegate = self
		addSubview(sceneView)
		
		let image = UIImage(named: "testStudio.jpg")
		sceneView.scene.lightingEnvironment.contents = image
		
		phantomNode.position.z = -1
		phantomNode.opacity = 0
		phantomAnchorNode.addChildNode(phantomNode)
		
		phantomAnchorNode.eulerAngles.x = -Float(45).degreesToRadians
		sceneView.scene.rootNode.addChildNode(phantomAnchorNode)
		
		sceneView.mask = UIView()
		sceneView.mask!.backgroundColor = UIColor(white: 0, alpha: 1)
		
		dotView.frame.size = CGSize(width: 4, height: 4)
		dotView.layer.cornerRadius = 2
		dotView.backgroundColor = UIColor.white
		self.dotView.alpha = ARArtView.dotViewStandardAlpha
		sceneView.addSubview(dotView)
		
		maskViewCutoutView.backgroundColor = UIColor.white
		maskViewCutoutView.frame.size = CGSize(
			width: ARArtView.cutoutRadius * 2,
			height: ARArtView.cutoutRadius * 2)
		maskViewCutoutView.layer.cornerRadius = ARArtView.cutoutRadius
		sceneView.mask!.addSubview(maskViewCutoutView)
		
		maskViewCutoutOutline.frame.size = maskViewCutoutView.frame.size
		maskViewCutoutOutline.layer.cornerRadius = maskViewCutoutView.layer.cornerRadius
		maskViewCutoutOutline.layer.borderWidth = 2
		maskViewCutoutOutline.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
		maskViewCutoutOutline.isHidden = true
		sceneView.addSubview(maskViewCutoutOutline)
		
		detailView.isHidden = true
		detailView.delegate = self
		addSubview(detailView)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		sceneView.frame = bounds
		sceneView.mask!.frame.size = sceneView.bounds.size
		dotView.center = focusPoint
		detailView.frame = bounds
		
		cachedBounds = sceneView.bounds
	}
	
	//Should be called on viewDidAppear
	func run(detectionImages: Set<ARReferenceImage>?) {
		// Create a session configuration
		let configuration = ARWorldTrackingConfiguration()
		configuration.detectionImages = detectionImages
		
		// Run the view's session
		sceneView.session.run(configuration)
	}
	
	//Should be called on viewDidDisappear
	func pause() {
		sceneView.session.pause()
	}
	
	private func setupArtwork() {
		guard let sceneArtwork = sceneArtwork else {
			return
		}
		
		for beacon in sceneArtwork.artwork.beacons {
			let beaconNode = BeaconNode()
			beaconNode.position = beacon.position
			beaconNode.animateIn(completion: nil)
			sceneArtwork.node.addChildNode(beaconNode)
			
			let sceneBeacon = SceneBeacon(node: beaconNode, beacon: beacon)
			sceneBeacons.append(sceneBeacon)
		}
		
		DispatchQueue.main.async {
			let label = UILabel()
			label.text = sceneArtwork.artwork.title
			label.font = UIFont.boldSystemFont(ofSize: 18)
			label.textAlignment = .center
			label.textColor = UIColor.black
			label.backgroundColor = UIColor.clear
			label.numberOfLines = 0
			label.frame.size = label.sizeThatFits(CGSize(width: 280, height: CGFloat.greatestFiniteMagnitude))
			
			let subheadingLabel = UILabel()
			subheadingLabel.text = "\(sceneArtwork.artwork.dateString), \(sceneArtwork.artwork.author)"
			subheadingLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
			subheadingLabel.textAlignment = .center
			subheadingLabel.textColor = UIColor(white: 0.35, alpha: 1.0)
			subheadingLabel.backgroundColor = UIColor.clear
			subheadingLabel.numberOfLines = 1
			subheadingLabel.sizeToFit()
			
			let titleView = UIView()
			titleView.addSubview(label)
			titleView.addSubview(subheadingLabel)
			titleView.frame.size = CGSize(
				width: ceil(label.frame.size.width + (ARArtView.titleLabelInset * 2)),
				height: ceil(label.frame.size.height + ARArtView.titleLabelSubtitleDifference +
					subheadingLabel.frame.size.height + (ARArtView.titleLabelInset * 2)))
			titleView.backgroundColor = UIColor.white
			titleView.layer.cornerRadius = 18
			label.center.x = titleView.frame.size.width / 2
			label.frame.origin.y = ARArtView.titleLabelInset
			subheadingLabel.center.x = titleView.frame.size.width / 2
			subheadingLabel.frame.origin.y = label.frame.origin.y + label.frame.size.height +
				ARArtView.titleLabelSubtitleDifference
			
			self.titleNode = BillboardInterfaceNode(view: titleView)
			self.titleNode.position.z = 0.05
			self.titleNode.position.y = Float(-(sceneArtwork.artwork.height * 0.5))
			self.titleNode.opacity = 0
			
			let fadeAction = SCNAction.fadeOpacity(to: CGFloat(ARArtView.titleNodeStandardAlpha), duration: 0.3)
			self.titleNode.runAction(fadeAction)
			
			let action = SCNAction.run() {
				node in
				node.addChildNode(self.titleNode)
			}
			
			sceneArtwork.node.runAction(action)
			
			let maxHeight = max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
			
			let artworkScale = (maxHeight / CGFloat(sceneArtwork.artwork.height)) * 0.618
			
			let phantomArtworkPlane = SCNPlane(
				width: CGFloat(sceneArtwork.artwork.width),
				height: CGFloat(sceneArtwork.artwork.height))
			phantomArtworkPlane.firstMaterial?.diffuse.contents = sceneArtwork.artwork.image
			
			let phantomArtworkNode = SCNNode()
			phantomArtworkNode.geometry = phantomArtworkPlane
			
			let phantomArtworkScaleNode = SCNNode()
			phantomArtworkScaleNode.scale = SCNVector3(artworkScale, artworkScale, artworkScale)
			phantomArtworkScaleNode.addChildNode(phantomArtworkNode)
			
			self.phantomNode.contentNode.addChildNode(phantomArtworkScaleNode)
			
			for beacon in sceneArtwork.artwork.beacons {
				let beaconNode = BeaconNode()
				beaconNode.position = beacon.position
				beaconNode.position.z = 0.01
				beaconNode.animateIn(completion: nil)
				phantomArtworkNode.addChildNode(beaconNode)
				
				let sceneBeacon = SceneBeacon(node: beaconNode, beacon: beacon)
				self.sceneBeacons.append(sceneBeacon)
			}
		}
		
		if sceneArtwork.node.parent == nil {
			self.sceneView.scene.rootNode.addChildNode(sceneArtwork.node)
		}
	}
	
	func animateInMaskView() {
		UIView.animate(withDuration: 0.4) {
			self.sceneView.mask!.backgroundColor = UIColor(white: 0, alpha: 0.65)
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
	
	func animateOutMaskView() {
		UIView.animate(withDuration: 0.2) {
			self.sceneView.mask!.backgroundColor = UIColor(white: 0, alpha: 1)
			self.dotView.alpha = ARArtView.dotViewStandardAlpha
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
}

extension ARArtView: ARSCNViewDelegate {
	func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
		guard let currentFrame = sceneView.session.currentFrame,
			let pov = sceneView.pointOfView else {
				return
		}
		
		if !isDisplayingPhantomArtwork && pov.eulerAngles.x < Float(-45).degreesToRadians {
			//Display phantom artwork
			isDisplayingPhantomArtwork = true
			
			let fadeAction = SCNAction.fadeIn(duration: 0.35)
			phantomNode.runAction(fadeAction)
		} else if isDisplayingPhantomArtwork && pov.eulerAngles.x > Float(-20).degreesToRadians {
			//Hide phantom artwork
			isDisplayingPhantomArtwork = false
			
			let fadeAction = SCNAction.fadeOut(duration: 0.35)
			phantomNode.runAction(fadeAction)
		}
		
		phantomAnchorNode.position = pov.position
		
		if let sceneArtwork = sceneArtwork {
			let rootNodePositionToNode = sceneView.scene.rootNode.convertPosition(SCNVector3Zero, from: sceneArtwork.node)
			let povPositionToNode = rootNodePositionToNode - pov.position
			
			let povHeadingToNode = SCNVector3Zero.heading(to: povPositionToNode)
			phantomAnchorNode.eulerAngles.y = -povHeadingToNode.horizontal
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
				let beaconPosition = activeBeacon.node.convertPosition(SCNVector3Zero, to: nil)
				
				let projectedPoint = renderer.projectPoint(beaconPosition)
				let projectedCGPoint = CGPoint(x: CGFloat(projectedPoint.x), y: CGFloat(projectedPoint.y))
				
				self.maskViewCutoutView.center = projectedCGPoint
				self.maskViewCutoutOutline.center = projectedCGPoint
			} else {
				for beacon in self.sceneBeacons {
					let beaconPosition = beacon.node.convertPosition(SCNVector3Zero, to: nil)
					let projectedPoint = renderer.projectPoint(beaconPosition)
					let projectedCGPoint = CGPoint(x: CGFloat(projectedPoint.x), y: CGFloat(projectedPoint.y))
					let distance = projectedCGPoint.distance(to: focusPoint)
					
					if distance < ARArtView.focusRadius {
						if let beaconFocus = self.beaconFocus {
							if beaconFocus.beacon.node == beacon.node,
								Date().timeIntervalSince(beaconFocus.focusDate) > ARArtView.focusDuration {
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
	
	func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
		guard let anchor = anchor as? ARImageAnchor else {
			return
		}
		
		if let anchor = anchor as? ARImageAnchor,
			let artwork = delegate?.artworkForDetectedImage(artView: self, image: anchor.referenceImage) {
			
			self.sceneArtwork = SceneArtwork(artwork: artwork, node: node)
		}
	}
	
	func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
		node.eulerAngles.x -= Float(90).degreesToRadians
		
		guard let pov = sceneView.pointOfView else {
			return
		}
	}
	
	func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
		guard let anchor = anchor as? ARImageAnchor else {
			return
		}
	}
}

extension ARArtView: DetailViewDelegate {
	func detailViewWasDismissed(detailView: DetailView) {
		activeBeacon = nil
	}
}
