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
	let artView = ARArtView()
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
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
