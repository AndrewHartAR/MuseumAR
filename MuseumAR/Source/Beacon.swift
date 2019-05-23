//
//  Beacon.swift
//  MuseumARSim
//
//  Created by Andrew Hart on 23/05/2019.
//  Copyright © 2019 Dent Reality. All rights reserved.
//

import Foundation

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
