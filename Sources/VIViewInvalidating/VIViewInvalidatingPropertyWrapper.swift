//
//  VIViewInvalidating.swift
//  VIViewInvalidating
//
//  Created by Darren Ford on 11/6/21.
//  Copyright © 2021 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

///
/// # @VIViewInvalidating
///
/// ## Overview
///
/// A swift `PropertyWrapper` to provide automatic `NSView`/`UIView` invalidation when the value is changed.
///
/// Provides built-in invalidations for
///
/// - needsDisplay (`.display`)
/// - needsLayout (`.layout`)
/// - needsUpdateConstraints (`.constraints`)
/// - invalidateIntrinsicContentSize() (`.intrinsicContentSize`)
/// - invalidateRestorableState() (`.restorableState`) [***macOS only***]
///
/// Reproduces `@Invalidating` in macOS systems prior to Monterey (12). Checked back to Xcode 11.4 (macOS 10.14)
///
/// ### Example
///
/// ```swift
/// class BadgeView: NSView {
///    // Automatically sets needsDisplay = true on the view when the value changes
///    @VIViewInvalidating(.display) var color: NSColor = NSColor.blue
/// }
/// ```
///
/// ## Custom invalidation
///
/// You can specify custom invalidation by conforming your view to the `VIViewCustomInvalidating` protocol.
///
/// ### Example
///
/// ```swift
/// class BadgeView: NSView  {
///    @VIViewInvalidating(.display) var color: NSColor = NSColor.blue
///    @VIViewInvalidating(.display) var backgroundColor: NSColor = NSColor.white
/// }
///
/// extension BadgeView: VIViewCustomInvalidating {
///    // Will be called when any `@VIViewInvalidating` property is updated in the view
///    func invalidate(view: NSView) {
///       Swift.print("custom invalidation!")
///    }
/// }
/// ```
///
/// ## Not recommended - Granular custom invalidation
///
/// **NOTE** that this behaviour is NOT compatible with Apple's `@Invalidating` property wrapper.  `@Invalidating` doesn't provide a similar functionality, so be aware when you move your build target up to macOS13/iOS15 there is no direct replacement so your code will break.
///
/// You can provide custom invalidators by defining a new class of type `VIViewInvalidatorAction`.
///
/// ```swift
/// class CustomInvalidator: VIViewInvalidatorAction {
///    public override func invalidate(_ view: VIViewType) {
///       Swift.print("Custom invalidator called")
///    }
/// }
///
/// class ExcitingView: NSView {
///    @VIViewInvalidating(.display) var color: NSColor = .white
///    @VIViewInvalidating(.display, CustomInvalidator()) var backgroundColor: NSColor = .systemBlue
///    override func draw(_ dirtyRect: NSRect) {
///       self.backgroundColor.setFill()
///       dirtyRect.fill()
///    }
/// }
/// ```
///


#if os(macOS)
import AppKit
/// Platform-specific View wrapper
public typealias VIViewType = NSView
#else
import UIKit
/// Platform-specific View wrapper
public typealias VIViewType = UIView
#endif

@available(swift 5.1)
@available(macOS, deprecated: 12.0, obsoleted: 14.0, message: "Use the built-in @Invalidating property wrapper for macOS 12 and above")
@available(iOS, deprecated: 15.0, obsoleted: 16.0, message: "Use the built-in @Invalidating property wrapper for iOS 15 and above")
@available(tvOS, deprecated: 15.0, obsoleted: 16.0, message: "Use the built-in @Invalidating property wrapper for tvOS 15 and above")

/// An invalidator class type
open class VIViewInvalidatorAction {
	public init() { }

	/// Will be called when the containing property is changed
	open func invalidate(_ view: VIViewType) {
		fatalError("Must override this method for custom invalidators")
	}

	// Built-in types

	/// `setNeedsDisplay`
	public static let display = VIViewInvalidatorAction.Display()
	/// `setNeedsUpdateConstraints`
	public static let constraints = VIViewInvalidatorAction.Constraints()
	/// `setNeedsLayout`
	public static let layout = VIViewInvalidatorAction.Layout()
	/// `invalidateIntrinsicContentSize`
	public static let intrinsicContentSize = VIViewInvalidatorAction.InstrinsicContentSize()

#if canImport(AppKit)
	/// `invalidateRestorableState`
	public static let restorableState = VIViewInvalidatorAction.RestorableState()
#endif
}

/// A property wrapper for NSView/UIView that will automatically invalidate the containing view
/// as its wrapped value is changed.
@propertyWrapper
public struct VIViewInvalidating<Value: Equatable> {
	/// Built-in invalidating types supported by the propertyWrapper
	private let invalidators: [VIViewInvalidatorAction]

	// Stored value
	private var valueType: Value

	/// Wrapped value
	public var wrappedValue: Value {
		get {
			return self.valueType
		}
		set {
			self.valueType = newValue
		}
	}

	/// Initialize with a built-in invalidating type.
	public init(wrappedValue: Value, _ invalidator: VIViewInvalidatorAction) {
		self.valueType = wrappedValue
		self.invalidators = [invalidator]
	}

	/// Initialize with a comma separated collection of built-in invalidating types
	public init(wrappedValue: Value, _ invalidators: VIViewInvalidatorAction...) {
		self.valueType = wrappedValue
		self.invalidators = invalidators.map { $0 }
	}

	/// Use a static subscript to get to the wrapper value via a keypath on the `VIViewType` instance
	///
	/// See (Swift By Sundell):
	///
	/// * [accessing-a-swift-property-wrappers-enclosing-instance](https://www.swiftbysundell.com/articles/accessing-a-swift-property-wrappers-enclosing-instance/)
	/// * [the-power-of-subscripts-in-swift](https://www.swiftbysundell.com/articles/the-power-of-subscripts-in-swift/#static-subscripts)
	public static subscript<EnclosingSelf: VIViewType>(
		_enclosingInstance object: EnclosingSelf,
		wrapped _: ReferenceWritableKeyPath<EnclosingSelf, Value>,
		storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, VIViewInvalidating<Value>>
	) -> Value {
		get {
			return object[keyPath: storageKeyPath].wrappedValue
		}
		set {
			// Update the propertyWrapper with the new value
			object[keyPath: storageKeyPath].updateViewInvalidatingPropertyWrapper(newValue, object)
		}
	}
}

// MARK: - Custom invalidation types

/// Custom view invalidating conformance
@available(swift 5.1)
@available(macOS, deprecated: 12.0, obsoleted: 14.0, message: "Use Apple's NSViewInvalidating protocol for macOS 12 and above")
@available(iOS, deprecated: 15.0, obsoleted: 16.0, message: "Use Apple's NSViewInvalidating protocol wrapper for iOS 15 and above")
@available(tvOS, deprecated: 15.0, obsoleted: 16.0, message: "Use Apple's NSViewInvalidating protocol wrapper for tvOS 15 and above")
public protocol VIViewCustomInvalidating {
	/// Called when a containing view implements the `VIViewInvalidating` protocol.
	func invalidate(view: VIViewType)
}

// MARK: - Value update handling

@available(swift 5.1)
@available(macOS, deprecated: 12.0, obsoleted: 14.0, message: "Use the built-in @Invalidating property wrapper for macOS 12 and above")
@available(iOS, deprecated: 15.0, obsoleted: 16.0, message: "Use the built-in @Invalidating property wrapper for iOS 15 and above")
@available(tvOS, deprecated: 15.0, obsoleted: 16.0, message: "Use the built-in @Invalidating property wrapper for tvOS 15 and above")
private extension VIViewInvalidating {
	// Update the value in the property wrapper with a new value, setting the appropriate view invalidations
	mutating func updateViewInvalidatingPropertyWrapper(_ value: Value, _ view: VIViewType) {
		guard self.wrappedValue != value else { return }

		// Update the wrapped value
		self.wrappedValue = value

		// And trigger the invalidations associated with the propertywrapper
		self.triggerInvalidations(view)
	}

	// Trigger the appropriate invalidations on `view`
	private func triggerInvalidations(_ view: VIViewType) {
		// Built-in invalidations
		self.invalidators.forEach { invalidator in
			invalidator.invalidate(view)
		}

		// Custom validation
		if let invalidatable = view as? VIViewCustomInvalidating {
			invalidatable.invalidate(view: view)
		}
	}
}

// MARK: - Built-in invalidator implementations

@available(swift 5.1)
@available(macOS, deprecated: 12.0, obsoleted: 14.0, message: "Use the built-in @Invalidating property wrapper for macOS 12 and above")
@available(iOS, deprecated: 15.0, obsoleted: 16.0, message: "Use the built-in @Invalidating property wrapper for iOS 15 and above")
@available(tvOS, deprecated: 15.0, obsoleted: 16.0, message: "Use the built-in @Invalidating property wrapper for tvOS 15 and above")
public extension VIViewInvalidatorAction {

	class Display: VIViewInvalidatorAction {
		public override func invalidate(_ view: VIViewType) {
#if os(macOS)
			view.needsDisplay = true
#else
			view.setNeedsDisplay()
#endif
		}
	}

	class Constraints: VIViewInvalidatorAction {
		public override func invalidate(_ view: VIViewType) {
#if os(macOS)
			view.needsUpdateConstraints = true
#else
			view.setNeedsUpdateConstraints()
#endif
		}
	}

	class Layout: VIViewInvalidatorAction {
		public override func invalidate(_ view: VIViewType) {
#if os(macOS)
			view.needsLayout = true
#else
			view.setNeedsLayout()
#endif
		}
	}

	class InstrinsicContentSize: VIViewInvalidatorAction {
		public override func invalidate(_ view: VIViewType) {
			view.invalidateIntrinsicContentSize()
		}
	}

#if canImport(AppKit)
	class RestorableState: VIViewInvalidatorAction {
		public override func invalidate(_ view: VIViewType) {
			view.invalidateRestorableState()
		}
	}
#endif
}


