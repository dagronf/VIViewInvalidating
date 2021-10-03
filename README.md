
# @VIViewInvalidating

A swift `PropertyWrapper` to provide automatic `NSView`/`UIView` invalidation when the properties value changes. It duplicates the `@Invalidating` propertyWrapper for build targets prior to macOS 12 and iOS 15.

<p align="center">
    <img src="https://img.shields.io/github/v/tag/dagronf/VIViewInvalidating" />
    <img src="https://img.shields.io/badge/macOS-10.11+-red" />
    <img src="https://img.shields.io/badge/iOS-11.0+-blue" />
    <img src="https://img.shields.io/badge/tvOS-11.0+-orange" />
    <img src="https://img.shields.io/badge/macCatalyst-1.0+-purple" />
</p>

<p align="center">
    <img src="https://img.shields.io/badge/Swift-5.1-orange.svg" />
    <img src="https://img.shields.io/badge/License-MIT-lightgrey" />
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" />
    </a>
</p>

## Why?

I saw in the WWDC2021 video ['What's new in AppKit'](https://developer.apple.com/wwdc21/10054) they make a brief mention of a new propertyWrapper type `@Invalidating()` that automatically updates views when the wrappedValue is changed. It appears this propertyWrapper is only available in later versions of AppKit (and presumably UIKit).

Given that a lot of AppKit/UIKit devs aren't going to be able to move their minimum target version to macOS 12 or iOS 15 soon I decided to try to replicate what I saw in the video.

`@VIViewInvalidating()` was born!

And once your target is set to macOS 13 or above, your `@VIViewInvalidating()` definitions will generate deprecation warnings telling you to move to `@Invalidating()`.

I've tried to make sure that the APIs are as close to `@Invalidating` as possible so moving your app target should in theory be as simple as changing some names

* `@VIViewInvalidating` -> `@Invalidating` 
* `VIViewCustomInvalidating` -> `UIViewInvalidating` (for iOS/tvOS)
* `VIViewCustomInvalidating` -> `NSViewInvalidating` (for macOS)


## Invalidating types

### Built-in

Provides built-in invalidators for

- needsDisplay (`.display`)
- needsLayout (`.layout`)
- needsUpdateConstraints (`.constraints`)
- invalidateIntrinsicContentSize() (`.intrinsicContentSize`)
- invalidateRestorableState() (`.restorableState`)    [***macOS only***]

#### Example

```swift
class BadgeView: NSView {
   // Automatically sets needsDisplay = true on the view when the value changes
   @VIViewInvalidating(.display) var color: NSColor = NSColor.blue
   
   // Set needsDisplay, needsLayout and invalidateIntrinsicContentSize() on 
   // the view when the value changes
   @VIViewInvalidating(.display, .layout, .intrinsicContentSize)
   var position: NSControl.ImagePosition = .imageLeft
}
```

## Custom invalidation

### Conforming your view to the `VIViewCustomInvalidating` protocol

The protocol method provides a very high-level callback when any of the `@VIViewInvalidating` properties are updated within your view. This is equivalent to the `NSViewInvalidating` protocol in later SDKs (macOS 12 and iOS 15)

#### Example

```swift
class BadgeView: NSView  {
   @VIViewInvalidating(.display) var color: NSColor = NSColor.blue
   @VIViewInvalidating(.display) var backgroundColor: NSColor = NSColor.white
}

extension BadgeView: VIViewCustomInvalidating {
   // Will be called when any `@VIViewInvalidating` property is updated in the view
   func invalidate(view: NSView) {
      Swift.print("custom invalidation!")
   }
}
```

### Providing your own invalidator (not recommended!)

**NOTE** that this behaviour is NOT compatible with Apple's `@Invalidating` property wrapper.  `@Invalidating` doesn't provide a similar functionality, so be aware when you move your build target up to macOS13/iOS15 there is no direct replacement so your code will break.

You can provide custom invalidators by defining a new class of type `VIViewType.VIViewInvalidatorAction`.

#### Example

```swift
class CustomInvalidator: VIViewInvalidatorAction {
   public override func invalidate(_ view: VIViewType) {
      Swift.print("Custom invalidator called")
   }
}

class ExcitingView: NSView {
   @VIViewInvalidating(.display) var color: NSColor = .white
   @VIViewInvalidating(.display, CustomInvalidator()) var backgroundColor: NSColor = .systemBlue
   override func draw(_ dirtyRect: NSRect) {
      self.backgroundColor.setFill()
      dirtyRect.fill()
   }
}
```

# Updates

### 3.0.0

* Added separate dynamic and static targets (thanks [BeehiveInnovations](https://github.com/BeehiveInnovations))!

### 2.0.1

* Resolved Swift runtime crash when building in Xcode 11 and Swift 5.1. Previous version would crash the Swift runtime as it tries to resolve generic arguments for a class nested in an extension. Removing the nested extension containing the property wrapper (it wasn't required) solved the issue. This has no impact when compiling with Xcode 12 and above.

### 2.0.0

* [**BREAKING**] Now that Apple has made `@Invalidating` available through Xcode, I've changed custom callback to match Apple's 'Invalidating' protocol to aid adoption when upgrading the SDK to one that supports `@Invalidating`.
* [**BREAKING**] Changed the mechanism for handling custom invalidations.
* Added `restorableState` as an invalidation type on macOS to be compatible with `@Invalidating` on macOS 12+

### 1.0.0

* Initial release

# Thanks

### John Sundell

[Twitter](https://twitter.com/johnsundell), [Swift By Sundell](https://www.swiftbysundell.com)

* [Accessing a swift property wrappers enclosing instance](https://www.swiftbysundell.com/articles/accessing-a-swift-property-wrappers-enclosing-instance/)
* [The power of subscripts in swift](https://www.swiftbysundell.com/articles/the-power-of-subscripts-in-swift/#static-subscripts)


# License

MIT. Use it for anything you want! Let me know if you do use it somewhere, I'd love to hear about it.

```
MIT License

Copyright (c) 2021 Darren Ford

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
