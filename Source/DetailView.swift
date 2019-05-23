//
//  DetailView.swift
//  MuseumARSim
//
//  Created by Andrew Hart on 21/05/2019.
//  Copyright © 2019 Dent Reality. All rights reserved.
//

import UIKit

protocol DetailViewDelegate: class {
	func detailViewWasDismissed(detailView: DetailView)
}

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
	
	weak var delegate: DetailViewDelegate?
	
	private var titleView = UILabel()
	private var summaryView = UILabel()
	
	private var dismissView = UILabel()
	
	private static let contentInset: CGFloat = 24
	
	private let button = UIButton()
	
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
		
		dismissView.font = UIFont.systemFont(ofSize: 16, weight: .bold)
		dismissView.text = "TAP TO DISMISS"
		dismissView.textColor = UIColor.white
		dismissView.sizeToFit()
		addSubview(dismissView)
		
		button.addTarget(self, action: #selector(respondToButtonTapped), for: .touchUpInside)
		addSubview(button)
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
		
		let dismissViewY = frame.size.height - DetailView.contentInset - safeAreaInsets.bottom - dismissView.frame.size.height
		
		dismissView.frame.origin = CGPoint(x: DetailView.contentInset, y: dismissViewY)
		
		let summaryViewY = dismissView.frame.origin.y - DetailView.contentInset - summaryView.frame.size.height
		
		summaryView.frame = CGRect(
			x: DetailView.contentInset,
			y: summaryViewY,
			width: summaryView.frame.size.width,
			height: summaryView.frame.size.height)
		
		titleView.frame = CGRect(
			x: DetailView.contentInset,
			y: summaryViewY - DetailView.contentInset - titleView.frame.size.height,
			width: titleView.frame.size.width, height: titleView.frame.size.height)
		
		button.frame = bounds
	}
	
	@objc func respondToButtonTapped() {
		delegate?.detailViewWasDismissed(detailView: self)
	}
}
