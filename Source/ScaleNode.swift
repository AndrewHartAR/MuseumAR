//
//  ScaleableNode.swift
//  MuseumARSim
//
//  Created by Andrew Hart on 20/05/2019.
//  Copyright © 2019 Dent Reality. All rights reserved.
//

import Foundation
import SceneKit

class ScaleNode: SCNNode {
	///The content which becomes scaled
	var contentNode = SCNNode()
	
	override init() {
		super.init()
		
		addChildNode(contentNode)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
