//
//  Artwork.swift
//  MuseumARSim
//
//  Created by Andrew Hart on 23/05/2019.
//  Copyright © 2019 Dent Reality. All rights reserved.
//

import Foundation
import SceneKit

class SceneArtwork {
	var node: SCNNode
	var artwork: Artwork
	
	init(artwork: Artwork, node: SCNNode) {
		self.artwork = artwork
		self.node = node
	}
}

struct Artwork {
	///A node representing the artwork
	///Doesn't necessarily represent it visually, but represents its' position in space
//	var node: SCNNode
	
	///Width of the artwork in meters
	var width: Float
	
	///Height of the artwork in meters
	var height: Float
	
	///Beacons representing content
	var beacons: [Beacon]
	
	var title: String
	var dateString: String
	var author: String
	var image: UIImage
}
