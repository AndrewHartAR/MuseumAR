//
//  SCNNode+Extensions.swift
//  MuseumARSim
//
//  Created by Andrew Hart on 20/05/2019.
//  Copyright © 2019 Dent Reality. All rights reserved.
//

import Foundation
import SceneKit

extension SCNNode {
	public func recursiveChildNodes() -> [SCNNode] {
		var nodes = [SCNNode]()
		
		for node in childNodes {
			nodes.append(contentsOf: node.recursiveChildNodes())
			nodes.append(node)
		}
		
		return nodes
	}
}
