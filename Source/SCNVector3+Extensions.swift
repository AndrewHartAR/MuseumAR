//
//  SCNVector3+Extensions.swift
//  MuseumARSim
//
//  Created by Andrew Hart on 20/05/2019.
//  Copyright © 2019 Dent Reality. All rights reserved.
//

import Foundation
import SceneKit

public struct Heading {
	public var horizontal: Float
	public var vertical: Float
	
	public init(horizontal: Float, vertical: Float) {
		self.horizontal = horizontal
		self.vertical = vertical
	}
	
	public static let zero = Heading(horizontal: 0, vertical: 0)
}

public extension SCNVector3 {
	///Gives bearing between 2 vectors
	public func heading(to point: SCNVector3) -> Heading {
		let horizontalHeading = atan2(point.x - self.x, self.z - point.z)
		
		let horizontalDistance = sqrt(pow(self.x - point.x, 2) + pow(self.z - point.z, 2))
		
		let verticalHeading = atan2(point.y - self.y, horizontalDistance)
		
		return Heading(horizontal: horizontalHeading, vertical: verticalHeading)
	}
	
	///Gives destination point, given a heading and distance
	public func destination(heading: Heading, horizontalDistance: Float) -> SCNVector3 {
		let x = horizontalDistance * sin(heading.horizontal)
		let z = 0 - (horizontalDistance * cos(heading.horizontal))
		
		let oppositeAngle = Float(180.0 - 90.0).degreesToRadians - heading.vertical
		
		let y = (horizontalDistance / sin(oppositeAngle)) * sin(heading.vertical)
		
		return SCNVector3(x: self.x + x, y: self.y + y, z: self.z + z)
	}
	
	public func distance(to point: SCNVector3) -> Float {
		return sqrt(pow(self.x - point.x, 2) + pow(self.y - point.y, 2) + pow(self.z - point.z, 2))
	}
	
	public static func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
		return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
	}
	
	public static func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
		return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
	}
	
	public static func / (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
		return SCNVector3Make(left.x / right.x, left.y / right.y, left.z / right.z)
	}
	
	public static func * (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
		return SCNVector3Make(left.x * right.x, left.y * right.y, left.z * right.z)
	}
}
