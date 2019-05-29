//
//  ViewController.swift
//  MuseumAR
//
//  Created by Andrew Hart on 13/05/2019.
//  Copyright © 2019 Dent Reality. All rights reserved.
//

import UIKit
import SceneKit

class SimViewController: UIViewController {
	let artView = ARArtView()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let paintingImage = UIImage(named: "image1")!
		
		artView.sceneView.scene.background.contents = UIColor.black
		
		let plane = SCNPlane(width: 3.367, height: 2.509)
		plane.firstMaterial?.diffuse.contents = paintingImage
		
		let planeNode = SCNNode(geometry: plane)
		planeNode.position.z = -2
		artView.sceneView.scene.rootNode.addChildNode(planeNode)
		
		var beacons = [Beacon]()
		
		let beacon1 = Beacon(
			contentTitle: "1759, A Year of Victories",
			contentSummary: "Admiral Sir Charles Saunders' powerful fleet anchored off the Ile d'Orleans on the St Lawrence River, below Quebec. At midnight, the French attacked with seven fire-ships and two fire-rafts. Saunders had received advance warning, and his men grappled the fire-vessels and towed them safely clear of his ships.",
			position: SCNVector3(-0.27, 0.11, 0))
		beacons.append(beacon1)
		
		let beacon2 = Beacon(
			contentTitle: "The Burning Fire-ships",
			contentSummary: "The British lie at anchor with Saunders' flagship the 'Stirling Castle', in port-bow view in the foreground. Immediately astern of her a ship appears to have cut her cable and is heading downstream.",
			position: SCNVector3(0.74, -0.34, 0))
		beacons.append(beacon2)
		
		let artworkNode = SCNNode()
		artworkNode.position.z = -2
		
		let artwork = Artwork(
			width: 2.15,
			height: 1.13,
			beacons: beacons,
			title: "French Fire Rafts Attacking the English Fleet off Quebec",
			dateString: "28 June 1759",
			author: "Samuel Scott",
			image: UIImage(named:"painting-image")!)
		
		let sceneArtwork = SceneArtwork(artwork: artwork, node: artworkNode)
		
		artView.sceneArtwork = sceneArtwork
		view.addSubview(artView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		
		artView.run(detectionImages: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
       	artView.pause()
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		artView.frame = view.bounds
	}
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
}
