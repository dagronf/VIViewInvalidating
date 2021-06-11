//
//  ViewController.swift
//  VIViewInvalidating Demo
//
//  Created by Darren Ford on 11/6/21.
//

import Cocoa

class ViewController: NSViewController {
	@IBOutlet var excitingView: ExcitingView!

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}

	override var representedObject: Any? {
		didSet {
			// Update the view, if already loaded.
		}
	}
}
