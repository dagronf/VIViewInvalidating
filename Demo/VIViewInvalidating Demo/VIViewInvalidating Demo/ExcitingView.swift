//
//  ExcitingView.swift
//  VIViewInvalidating Demo
//
//  Created by Darren Ford on 11/6/21.
//

import AppKit
import VIViewInvalidating

extension VIViewType.VIViewInvalidatingType {
	static let custom1 = VIViewType.VIViewInvalidatingType("ci1")
	static let custom2 = VIViewType.VIViewInvalidatingType("ci2")
}

@IBDesignable
class ExcitingView: NSView, VIViewCustomInvalidating {
	@IBInspectable
	@VIViewInvalidating(.display, .custom1, .custom2)
	var backgroundColor: NSColor = .systemBlue

	override func draw(_ dirtyRect: NSRect) {
		self.backgroundColor.setFill()
		dirtyRect.fill()
	}

	// Custom invalidation handling
	func performViewInvalidation(_ customInvalidationTypes: VIViewType.VIViewInvalidatingTypes) {
		Swift.print(customInvalidationTypes)
	}

}
