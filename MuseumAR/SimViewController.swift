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

class SimViewController: UIViewController, ARSCNViewDelegate {
    let sceneView = ARSCNView()
	
	let artworkNode = SCNNode()
	
	let beacon1Node = BeaconNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
		view.addSubview(sceneView)
		
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
		
		let plane = SCNPlane(width: 3.367, height: 2.509)
		plane.firstMaterial?.diffuse.contents = paintingImage
		
		let planeNode = SCNNode(geometry: plane)
		planeNode.position.z = -2
		sceneView.scene.rootNode.addChildNode(planeNode)
		
		let artworkPlane = SCNPlane(width: 2.15, height: 1.13)
		artworkPlane.firstMaterial?.diffuse.contents = UIColor.blue.withAlphaComponent(0.35)
		artworkNode.geometry = artworkPlane
		artworkNode.position.z = 0.1
		planeNode.addChildNode(artworkNode)
		
		beacon1Node.position.z = 0.1
		artworkNode.addChildNode(beacon1Node)
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
	}

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
