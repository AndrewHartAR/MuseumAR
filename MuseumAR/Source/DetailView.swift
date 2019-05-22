//
//  DetailView.swift
//  MuseumARSim
//
//  Created by Andrew Hart on 21/05/2019.
//  Copyright © 2019 Dent Reality. All rights reserved.
//

import UIKit

class DetailView: UIView {
	var title: String? {
		set {
			titleView.text = newValue
		}
		get {
			return titleView.text
		}
	}
	
	var summary: String? {
		set {
			summaryView.text = newValue
		}
		get {
			return summaryView.text
		}
	}
	
	private var titleView = UILabel()
	private var summaryView = UILabel()
	
	private static let contentInset: CGFloat = 24
	
	init() {
		super.init(frame: CGRect.zero)
		
		titleView.font = UIFont.systemFont(ofSize: 20, weight: .bold)
		titleView.textColor = UIColor.white
		titleView.numberOfLines = 0
		addSubview(titleView)
		
		summaryView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
		summaryView.textColor = UIColor.white
		summaryView.numberOfLines = 0
		addSubview(summaryView)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		let maxSize = CGSize(
			width: max(0, frame.size.width - (DetailView.contentInset * 2)),
			height: CGFloat.greatestFiniteMagnitude)
		
		titleView.frame.size = titleView.sizeThatFits(maxSize)
		summaryView.frame.size = summaryView.sizeThatFits(maxSize)
		
		let summaryViewY = frame.size.height - DetailView.contentInset - safeAreaInsets.bottom - summaryView.frame.size.height
		
		summaryView.frame = CGRect(
			x: DetailView.contentInset,
			y: summaryViewY,
			width: summaryView.frame.size.width,
			height: summaryView.frame.size.height)
		
		titleView.frame = CGRect(
			x: DetailView.contentInset,
			y: summaryViewY - DetailView.contentInset - titleView.frame.size.height,
			width: titleView.frame.size.width, height: titleView.frame.size.height)
	}
}
