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
/// You can specify custom invalidation types by conforming your view to the `VIViewCustomInvalidating` protocol.
///
/// ### Example
///
/// ```swift
/// extension VIViewType.VIViewInvalidatingType {
///    static let customInvalidation = VIViewType.VIViewInvalidatingType(rawValue: "customInvalidation")
/// }
///
/// class BadgeView: NSView, VIViewCustomInvalidating  {
///    @VIViewInvalidating(.display, .customInvalidation) var color: NSColor = NSColor.blue
///
///    func performViewInvalidation(_ customInvalidationTypes: VIViewInvalidatingTypes) {
///       Swift.print(customInvalidationTypes)
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

@available(macOS, deprecated: 12.0, obsoleted: 14.0, message: "Use the built-in @Invalidating property wrapper for macOS 12 and above")
@available(iOS, deprecated: 15.0, obsoleted: 16.0, message: "Use the built-in @Invalidating property wrapper for iOS 15 and above")
@available(tvOS, deprecated: 15.0, obsoleted: 16.0, message: "Use the built-in @Invalidating property wrapper for tvOS 15 and above")
extension VIViewType {
	/// Built-in view invalidation types. Can be extended with new custom types if needed
	public struct VIViewInvalidatingType: Hashable, CustomDebugStringConvertible {

		public let rawValue: String

		/// Returns a debug description for the VIViewInvalidatingType type
		public var debugDescription: String {
			return "VIViewInvalidatingType('\(rawValue)')"
		}

		/// Initializer
		public init(_ rawValue: String) {
			self.rawValue = rawValue
		}

		// Built-in types

		/// `setNeedsDisplay`
		public static let display = VIViewInvalidatingType("_display")
		/// `setNeedsUpdateConstraints`
		public static let constraints = VIViewInvalidatingType("_constraints")
		/// `setNeedsLayout`
		public static let layout = VIViewInvalidatingType("_layout")
		/// `invalidateIntrinsicContentSize`
		public static let intrinsicContentSize = VIViewInvalidatingType("_intrinsicContentSize")

		// All built-in types
		fileprivate static let allBuiltIn: [VIViewInvalidatingType] = [.display, .constraints, .layout, .intrinsicContentSize]
	}

	/// Wrapper for a collection of invalidation types
	public typealias VIViewInvalidatingTypes = Set<VIViewType.VIViewInvalidatingType>
}

@available(macOS, deprecated: 12.0, obsoleted: 14.0, message: "Use the built-in @Invalidating property wrapper for macOS 12 and above")
@available(iOS, deprecated: 15.0, obsoleted: 16.0, message: "Use the built-in @Invalidating property wrapper for iOS 15 and above")
@available(tvOS, deprecated: 15.0, obsoleted: 16.0, message: "Use the built-in @Invalidating property wrapper for tvOS 15 and above")
extension VIViewType {
	/// A property wrapper for NSView/UIView that will automatically invalidate the containing view
	/// as its wrapped value is changed.
	@propertyWrapper
	public struct VIViewInvalidating<Value: Equatable> {
		/// Built-in invalidating types supported by the propertyWrapper
		public let types: VIViewInvalidatingTypes

		/// custom invalidating types supported by the propertyWrapper
		public let customTypes: VIViewInvalidatingTypes

		/// Are custom types defined for this property?
		@inlinable public var hasCustomTypes: Bool { !self.customTypes.isEmpty }

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
		public init(wrappedValue: Value, _ type: VIViewInvalidatingType) {
			self.valueType = wrappedValue
			self.types = Set([type])
			self.customTypes = self.types.subtracting(VIViewInvalidatingType.allBuiltIn)
		}

		/// Initialize with a comma separated collection of built-in invalidating types
		public init(wrappedValue: Value, _ types: VIViewInvalidatingType...) {
			self.valueType = wrappedValue
			self.types = Set(types.map { $0 })
			self.customTypes = self.types.subtracting(VIViewInvalidatingType.allBuiltIn)
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
}

// MARK: - Custom invalidation types

/// Custom view invalidating conformance
@available(macOS, deprecated: 12.0, obsoleted: 14.0, message: "Use the built-in @Invalidating property wrapper for macOS 12 and above")
@available(iOS, deprecated: 15.0, obsoleted: 16.0, message: "Use the built-in @Invalidating property wrapper for iOS 15 and above")
@available(tvOS, deprecated: 15.0, obsoleted: 16.0, message: "Use the built-in @Invalidating property wrapper for tvOS 15 and above")
public protocol VIViewCustomInvalidating {
	/// Called when a ViewInvalidation specifies one or more custom invalidation types.
	/// `customInvalidationType` contains only the custom validation types specified, and none of the built-in (if they were also specified)
	func performViewInvalidation(_ customInvalidationTypes: VIViewType.VIViewInvalidatingTypes)
}

// MARK: - Value update handling

@available(macOS, deprecated: 12.0, obsoleted: 14.0, message: "Use the built-in @Invalidating property wrapper for macOS 12 and above")
@available(iOS, deprecated: 15.0, obsoleted: 16.0, message: "Use the built-in @Invalidating property wrapper for iOS 15 and above")
@available(tvOS, deprecated: 15.0, obsoleted: 16.0, message: "Use the built-in @Invalidating property wrapper for tvOS 15 and above")
private extension VIViewType.VIViewInvalidating {
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

		if types.contains(.display) {
			self.invalidateNeedsDisplay(view)
		}
		if types.contains(.constraints) {
			self.invalidateNeedsUpdateConstraints(view)
		}
		if types.contains(.layout) {
			self.invalidateNeedsUpdateLayout(view)
		}
		if types.contains(.intrinsicContentSize) {
			self.updateInvalidateIntrinsicContentSize(view)
		}

		if hasCustomTypes {
			self.invalidateCustomTypes(view)
		}
	}

	private func invalidateCustomTypes(_ view: VIViewType) {
		assert(hasCustomTypes)

		// Call custom invalidation routine if view is conformant and we have custom types specified
		if let view = view as? VIViewCustomInvalidating {
			view.performViewInvalidation(customTypes)
		}
		else {
			let warningMsg = "Warning: Custom ViewInvalidating type(s) \(customTypes.map { $0.rawValue }) assigned to non-conforming view \(view)"
			assert(false, warningMsg)
			Swift.debugPrint(warningMsg)
		}
	}

	// MARK: - NSView/UIView Platform wrappers

	private func invalidateNeedsDisplay(_ view: VIViewType) {
		#if os(macOS)
		view.needsDisplay = true
		#else
		view.setNeedsDisplay()
		#endif
	}

	private func invalidateNeedsUpdateConstraints(_ view: VIViewType) {
		#if os(macOS)
		view.needsUpdateConstraints = true
		#else
		view.setNeedsUpdateConstraints()
		#endif
	}

	private func invalidateNeedsUpdateLayout(_ view: VIViewType) {
		#if os(macOS)
		view.needsLayout = true
		#else
		view.setNeedsLayout()
		#endif
	}

	private func updateInvalidateIntrinsicContentSize(_ view: VIViewType) {
		view.invalidateIntrinsicContentSize()
	}
}
