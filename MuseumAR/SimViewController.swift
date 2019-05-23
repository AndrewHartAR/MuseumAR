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
		
		let node = SCNNode()
		node.position.z = -2
		
		let artwork = Artwork(
			node: node,
			width: 2.15,
			height: 1.13,
			beacons: [],
			title: "French Fire Rafts Attacking the English Fleet off Quebec",
			dateString: "28 June 1759",
			author: "Samuel Scott")
		artView.artwork = artwork
		view.addSubview(artView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		
		artView.run()
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
