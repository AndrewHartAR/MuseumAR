//
//  BillboardInterfaceNode.swift
//  MuseumARSim
//
//  Created by Andrew Hart on 23/05/2019.
//  Copyright © 2019 Dent Reality. All rights reserved.
//

import Foundation
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
