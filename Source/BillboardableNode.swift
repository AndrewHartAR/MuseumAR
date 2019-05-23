//
//  BillboardableNode.swift
//  MuseumARSim
//
//  Created by Andrew Hart on 20/05/2019.
//  Copyright © 2019 Dent Reality. All rights reserved.
//

import Foundation
import SceneKit

enum BillboardDirection {
	case horizontal
	case vertical
}

protocol BillboardableNode: SCNNode {
	var directions: [BillboardDirection] { get set }
	
	var billboardContentNode: SCNNode { get set }
}
