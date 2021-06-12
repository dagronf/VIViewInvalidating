//
//  ExcitingView.swift
//  VIViewInvalidating Demo
//
//  Created by Darren Ford on 11/6/21.
//

import UIKit
import VIViewInvalidating

@IBDesignable
class ExcitingView: UIView {

	@IBInspectable
	@VIViewInvalidating(.display)
	var fillColor: UIColor = .systemBlue

	override func draw(_ rect: CGRect) {
		fillColor.setFill()

		let path = UIBezierPath(rect: rect)
		path.fill()
	}
}
