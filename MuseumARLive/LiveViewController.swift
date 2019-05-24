//
//  ViewController.swift
//  MuseumARLive
//
//  Created by Andrew Hart on 23/05/2019.
//  Copyright © 2019 Dent Reality. All rights reserved.
//

import UIKit
import ARKit

///This works in a live museum context
///Use this as a guide for how you might replace the sample content with your own content
///You can also try this project in-person at the Maritime Museum in Greenwich, London.
class LiveViewController: UIViewController {
	let artView = ARArtView()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		artView.delegate = self
		view.addSubview(artView)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil)
		
		artView.run(detectionImages: referenceImages)
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
}

extension LiveViewController: ARArtViewDelegate {
	func artworkForDetectedImage(artView: ARArtView, image: ARReferenceImage) -> Artwork? {
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

		let artwork = Artwork(
			width: 2.15,
			height: 1.13,
			beacons: beacons,
			title: "French Fire Rafts Attacking the English Fleet off Quebec",
			dateString: "28 June 1759",
			author: "Samuel Scott")
		
		return artwork
	}
}

