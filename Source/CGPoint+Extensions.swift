//
//  CGPoint+Extensions.swift
//  MuseumARSim
//
//  Created by Andrew Hart on 21/05/2019.
//  Copyright © 2019 Dent Reality. All rights reserved.
//

import Foundation
import UIKit

public extension CGPoint {
	///Gives bearing between 2 vectors
	func heading(to point: CGPoint) -> CGFloat {
		let heading = atan2(point.x - self.x, point.y - self.y)
		
		return heading
	}
	
	///Gives destination point, given a heading and distance
	func destination(heading: CGFloat, distance: CGFloat) -> CGPoint {
		let x = distance * sin(heading)
		let y = distance * cos(heading)
		
		return CGPoint(x: self.x + x, y: self.y + y)
	}
	
	func distance(to point: CGPoint) -> CGFloat {
		return sqrt(pow(self.x - point.x, 2) + pow(self.y - point.y, 2))
	}
}
