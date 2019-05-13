//
//  FloatingPoint+Extensions.swift
//  MuseumAR
//
//  Created by Andrew Hart on 13/05/2019.
//  Copyright © 2019 Dent Reality. All rights reserved.
//

import Foundation

public extension FloatingPoint {
	public var degreesToRadians: Self { return self * .pi / 180 }
	public var radiansToDegrees: Self { return self * 180 / .pi }
}
