//
//  ViewController.swift
//  MuseumAR
//
//  Created by Andrew Hart on 13/05/2019.
//  Copyright © 2019 Dent Reality. All rights reserved.
//

import UIKit

class SimViewController: UIViewController {
	let artView = ARArtView()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		view.addSubview(artView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		
		artView.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
       	artView.pause()
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		artView.frame = view.bounds
	}
}
