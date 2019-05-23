//
//  Beacon.swift
//  MuseumARSim
//
//  Created by Andrew Hart on 23/05/2019.
//  Copyright © 2019 Dent Reality. All rights reserved.
//

import SceneKit

class SceneBeacon {
	var node: BeaconNode
	var beacon: Beacon
	
	init(node: BeaconNode, beacon: Beacon) {
		self.node = node
		self.beacon = beacon
	}
}

class Beacon {
	var contentTitle: String
	var contentSummary: String
	
	///Position on the artwork, measured from the middle, in meters
	var position: SCNVector3
	
	init(contentTitle: String, contentSummary: String, position: SCNVector3) {
		self.contentTitle = contentTitle
		self.contentSummary = contentSummary
		self.position = position
	}
}
