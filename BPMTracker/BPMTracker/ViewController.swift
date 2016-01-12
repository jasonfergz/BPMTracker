//
//  ViewController.swift
//  BPMTracker
//
//  Created by Jason Ferguson on 11/14/15.
//  Copyright © 2015 Jason Ferguson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	var connectionManager: BTConnectionManager?

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		connectionManager = BTConnectionManager()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

