//
//  SimBackgroundImage.swift
//  MuseumAR
//
//  Created by Andrew Hart on 13/05/2019.
//  Copyright © 2019 Dent Reality. All rights reserved.
//

import UIKit

struct SimBackgroundImage {
	//	Horizontal span of the image, in degrees
	var image: UIImage
	
	var horizontalSpan: Float
}

extension SimBackgroundImage {
	private static let maximumSkyboxHeight: CGFloat = 4000
	
	func skyboxImage() -> UIImage? {
		let skyboxImageWidth = image.size.width / CGFloat(horizontalSpan / Float(360).degreesToRadians)
		
		var skyboxImageSize = CGSize(
			width: skyboxImageWidth,
			height: skyboxImageWidth * 0.5)
		
		var resizedImageSize = image.size
		
		if skyboxImageSize.height > SimBackgroundImage.maximumSkyboxHeight {
			let scale = SimBackgroundImage.maximumSkyboxHeight / skyboxImageSize.height
			
			skyboxImageSize = CGSize(
				width: skyboxImageSize.width * scale,
				height: skyboxImageSize.height * scale)
			resizedImageSize = CGSize(
				width: image.size.width * scale,
				height: image.size.height * scale)
		}
		
		let imageFrame = CGRect(
			x: (skyboxImageSize.width / 2) - (resizedImageSize.width / 2),
			y: (skyboxImageSize.height / 2) - (resizedImageSize.height / 2),
			width: resizedImageSize.width,
			height: resizedImageSize.height)
		
		UIGraphicsBeginImageContextWithOptions(skyboxImageSize, true, 1.0)
		var adjustedImageFrame = imageFrame
		adjustedImageFrame.origin.x += skyboxImageSize.width / 4
		image.draw(in: adjustedImageFrame)
		adjustedImageFrame.origin.x -= skyboxImageSize.width
		image.draw(in: adjustedImageFrame)
		let skyboxImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return skyboxImage
	}
}
