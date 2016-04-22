//
//  UIViewExtension.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2016 Susan Cheng. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

public extension UIView {
    
    /// The radius to use when drawing rounded corners for the layer’s background. Animatable.
    ///
    /// Setting the radius to a value greater than `0.0` causes the layer to begin drawing rounded corners on its
    /// background. By default, the corner radius does not apply to the image in the layer’s contents property; it
    /// applies only to the background color and border of the layer. However, setting the masksToBounds property to
    /// true causes the content to be clipped to the rounded corners.
    ///
    /// The default value of this property is `0.0`.
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
}

public extension UIView {
    
    /// The width of the layer’s border. Animatable.
    ///
    /// When this value is greater than `0.0`, the layer draws a border using the current `borderColor` value. The
    /// border is drawn inset from the receiver’s bounds by the value specified in this property. It is composited
    /// above the receiver’s contents and sublayers and includes the effects of the `cornerRadius` property.
    ///
    /// The default value of this property is `0.0`.
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    /// The color of the layer’s border. Animatable.
    ///
    /// The default value of this property is an opaque black color.
    ///
    /// The value of this property is retained using the Core Foundation retain/release semantics. This behavior
    /// occurs despite the fact that the property declaration appears to use the default assign semantics for
    /// object retention.
    @IBInspectable var borderColor: UIColor? {
        get {
            return layer.borderColor.map(UIColor.init)
        }
        set {
            layer.borderColor = newValue?.CGColor
        }
    }
}

public extension UIView {
    
    /// The color of the layer’s shadow. Animatable.
    ///
    /// The default value of this property is an opaque black color.
    ///
    /// The value of this property is retained using the Core Foundation retain/release semantics. This behavior
    /// occurs despite the fact that the property declaration appears to use the default assign semantics for
    /// object retention.
    @IBInspectable var shadowColor: UIColor? {
        get {
            return layer.shadowColor.map(UIColor.init)
        }
        set {
            layer.shadowColor = newValue?.CGColor
        }
    }
    
    /// The opacity of the layer’s shadow. Animatable.
    ///
    /// The value in this property must be in the range `0.0` (transparent) to `1.0` (opaque). The default
    /// value of this property is `0.0`.
    @IBInspectable var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    /// The offset (in points) of the layer’s shadow. Animatable.
    ///
    /// The default value of this property is `(0.0, -3.0)`.
    @IBInspectable var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    /// The blur radius (in points) used to render the layer’s shadow. Animatable.
    ///
    /// You specify the radius The default value of this property is `3.0`.
    @IBInspectable var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
}

public extension UIView {
    
    /// A Boolean that indicates whether the geometry of the layer and its sublayers is flipped vertically.
    ///
    /// If the layer is providing the backing for a layer-backed view, the view is responsible for managing
    /// the value in this property. For standalone layers, this property controls whether geometry values for
    /// the layer are interpreted using the standard or flipped coordinate system. The value of this property
    /// does not affect the rendering of the layer’s content.
    ///
    /// The default value of this property is `false`.
    @IBInspectable var geometryFlipped: Bool {
        get {
            return layer.geometryFlipped
        }
        set {
            layer.geometryFlipped = newValue
        }
    }
}
