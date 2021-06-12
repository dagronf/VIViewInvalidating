//
//  ExcitingView.swift
//  VIViewInvalidating Demo
//
//  Created by Darren Ford on 11/6/21.
//

import AppKit
import VIViewInvalidating

@IBDesignable
class ExcitingView: NSView {

	@IBInspectable
	@VIViewInvalidating(.display)
	var backgroundColor: NSColor = .systemBlue

	override func draw(_ dirtyRect: NSRect) {
		self.backgroundColor.setFill()
		dirtyRect.fill()
	}

}
