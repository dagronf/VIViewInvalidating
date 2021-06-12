
# @VIViewInvalidating

A swift `PropertyWrapper` to provide automatic `NSView`/`UIView` invalidation when the properties value changes. It copies the `@Invalidating` propertyWrapper for code targets prior to macOS 12 and iOS 15.

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

I saw in the WWDC2021 video ['What's new in AppKit'](https://developer.apple.com/wwdc21/10054) they make a brief mention of a new propertyWrapper type `@Invalidating()` that automatically updates views when the wrappedValue is changed. It appears this propertyWrapper is available in later versions of AppKit (and presumably UIKit).

Given that a lot of AppKit/UIKit devs aren't going to be able to move their minimum target version to macOS 13 or iOS 15 soon I decided to try to replicate what I saw in the video.

`@VIViewInvalidating()` was born!

And once your target is set to macOS 13 or above, your `@VIViewInvalidating()` definitions will generate deprecation warnings telling you to move to `@Invalidating()`.

## Invalidating types

### Built-in

Provides built-in invalidators for

- needsDisplay (`.display`)
- needsLayout (`.layout`)
- needsUpdateConstraints (`.constraints`)
- invalidateIntrinsicContentSize() (`.intrinsicContentSize`)

#### Example

```swift
class BadgeView: NSView {
   // Automatically sets needsDisplay = true on the view when the value changes
   @VIViewInvalidating(.display) var color: NSColor = NSColor.blue
   
   // Set needsDisplay, needsLayout and invalidateIntrinsicContentSize() on the view when the value changes
   @VIViewInvalidating(.display, .layout, .intrinsicContentSize)
   var position: NSControl.ImagePosition = .imageLeft
}
```

### Custom invalidation

You can specify custom invalidation types by conforming your view to the `VIViewCustomInvalidating` protocol and defining a new instance of `VIViewType.VIViewInvalidatingType`

#### Example

```swift
extension VIViewType.VIViewInvalidatingType {
   static let customInvalidation = VIViewType.VIViewInvalidatingType("customInvalidation")
}

class BadgeView: NSView, VIViewCustomInvalidating  {
   @VIViewInvalidating(.display, .customInvalidation) var color: NSColor = NSColor.blue

   // Will be called when a property with custom invalidation(s) is given a new value
   func performViewInvalidation(_ customInvalidationTypes: VIViewInvalidatingTypes) {
      Swift.print(customInvalidationTypes)
   }
}
```

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
