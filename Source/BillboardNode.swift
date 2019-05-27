//
//  BillboardNode.swift
//  MuseumAR
//
//  Created by Andrew Hart on 27/05/2019.
//  Copyright © 2019 Dent Reality. All rights reserved.
//

import Foundation
import SceneKit

class BillboardNode: SCNNode, BillboardableNode {
	var directions: [BillboardDirection]
	
	var billboardContentNode = SCNNode()
	
	init(directions: [BillboardDirection]) {
		self.directions = directions
		
		super.init()
		
		addChildNode(billboardContentNode)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
