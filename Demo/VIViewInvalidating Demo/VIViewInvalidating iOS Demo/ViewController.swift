//
//  ViewController.swift
//  VIViewInvalidating iOS Demo
//
//  Created by Darren Ford on 11/6/21.
//

import UIKit

class ViewController: UIViewController {


	@IBOutlet weak var excitingView: ExcitingView!
	@IBOutlet weak var hueSlider: UISlider!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.

		let selectedColor = excitingView.fillColor

		var hue: CGFloat = 0.0
		selectedColor.getHue(&hue, saturation: nil, brightness: nil, alpha: nil)

		hueSlider.value = Float(hue)

	}

	@IBAction func hueValueDidChange(_ sender: UISlider) {

		let newValue = CGFloat(sender.value)
		let newColor = UIColor(hue: newValue, saturation: 1, brightness: 1, alpha: 1)
		excitingView.fillColor = newColor
	}


}

