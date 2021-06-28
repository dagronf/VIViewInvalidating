//
//  ExcitingView.swift
//  VIViewInvalidating Demo
//
//  Created by Darren Ford on 11/6/21.
//

import UIKit
import VIViewInvalidating

// Custom Invalidator
class MyCustomInvalidator: VIViewInvalidatorAction {
	public override func invalidate(_ view: VIViewType) {
		Swift.print("MyCustomInvalidator called...")
	}
}

@IBDesignable
class ExcitingView: UIView {

	@IBInspectable
	@VIViewInvalidating(.display, MyCustomInvalidator())
	var fillColor: UIColor = .systemBlue

	override func draw(_ rect: CGRect) {
		fillColor.setFill()

		let path = UIBezierPath(rect: rect)
		path.fill()
	}
}

extension ExcitingView: VIViewCustomInvalidating {

	// Custom invalidation handling
	func invalidate(view: UIView) {
		Swift.print("custom invalidate!")
	}
}
