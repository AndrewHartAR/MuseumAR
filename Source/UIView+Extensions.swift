//
//  UIView+Extensions.swift
//  MuseumARSim
//
//  Created by Andrew Hart on 24/05/2019.
//  Copyright © 2019 Dent Reality. All rights reserved.
//

import UIKit

extension UIView {
	func image() -> UIImage? {
		UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)
		defer { UIGraphicsEndImageContext() }
		if let context = UIGraphicsGetCurrentContext() {
			layer.render(in: context)
			let image = UIGraphicsGetImageFromCurrentImageContext()
			return image
		}
		return nil
	}
}
