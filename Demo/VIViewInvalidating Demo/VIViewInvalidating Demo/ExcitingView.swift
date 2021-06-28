//
//  ExcitingView.swift
//  VIViewInvalidating Demo
//
//  Created by Darren Ford on 11/6/21.
//

import AppKit
import VIViewInvalidating

// Custom Invalidator
class MyCustomInvalidator: VIViewInvalidatorAction {
	public override func invalidate(_ view: VIViewType) {
		Swift.print("MyCustomInvalidator called...")
	}
}

@IBDesignable
class ExcitingView: NSView {
	@IBInspectable
	@VIViewInvalidating(.display, MyCustomInvalidator())
	var backgroundColor: NSColor = .systemBlue

	override func draw(_ dirtyRect: NSRect) {
		self.backgroundColor.setFill()
		dirtyRect.fill()
	}
}

extension ExcitingView: VIViewCustomInvalidating {

	// Custom invalidation handling
	func invalidate(view: NSView) {
		Swift.print("custom invalidate!")
	}
}
