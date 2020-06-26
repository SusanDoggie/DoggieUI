//
//  UIKitExtension.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2020 Susan Cheng. All rights reserved.
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

extension UIView {
    
    open var screen: UIScreen? {
        return window?.screen
    }
}

extension UIView {
    
    open var firstResponder: UIView? {
        
        guard !isFirstResponder else { return self }
        
        for subview in subviews {
            if let firstResponder = subview.firstResponder {
                return firstResponder
            }
        }
        
        return nil
    }
}

extension UIViewController {
    
    open var firstResponder: UIView? {
        return self.view?.firstResponder
    }
}

extension UIView {
    
    open class func loadNib(name: String, bundle: Bundle? = nil, owner: Any? = nil, options: [UINib.OptionsKey: Any]? = nil) -> UIView? {
        
        return UINib(nibName: name, bundle: bundle).instantiate(withOwner: owner, options: options)[0] as? UIView
    }
}

extension CALayer {
    
    open func addAnimation(duration: CFTimeInterval, from: AnyObject, to: AnyObject, timingFunction: CAMediaTimingFunction? = nil, forKey key: String) {
        
        let animate = CABasicAnimation(keyPath: key)
        animate.duration = 0.1
        animate.fromValue = from
        animate.toValue = to
        animate.timingFunction = timingFunction
        self.setValue(to, forKey: key)
        self.add(animate, forKey: key)
    }
}

extension UIView: RandomAccessCollection, MutableCollection {
    
    public typealias Indices = CountableRange<Int>
    
    public typealias Index = Int
    
    open var startIndex: Int {
        return subviews.startIndex
    }
    
    open var endIndex: Int {
        return subviews.endIndex
    }
    
    open subscript(position: Int) -> UIView {
        get {
            return subviews[position]
        }
        set {
            subviews[position].removeFromSuperview()
            self.insertSubview(newValue, at: position)
        }
    }
}

extension UIView {
    
    /// When true, the layer is rendered as a bitmap in its local coordinate
    /// space ("rasterized"), then the bitmap is composited into the
    /// destination (with the minificationFilter and magnificationFilter
    /// properties of the layer applied if the bitmap needs scaling).
    /// Rasterization occurs after the layer's filters and shadow effects
    /// are applied, but before the opacity modulation. As an implementation
    /// detail the rendering engine may attempt to cache and reuse the
    /// bitmap from one frame to the next. (Whether it does or not will have
    /// no affect on the rendered output.)
    ///
    /// When false the layer is composited directly into the destination
    /// whenever possible (however, certain features of the compositing
    /// model may force rasterization, e.g. adding filters).
    ///
    /// Defaults to NO. Animatable.
    @IBInspectable open var shouldRasterize: Bool {
        get {
            return layer.shouldRasterize
        }
        set {
            layer.shouldRasterize = newValue
        }
    }
    
    /// The scale at which the layer will be rasterized (when the
    /// shouldRasterize property has been set to YES) relative to the
    /// coordinate space of the layer. Defaults to one. Animatable.
    @IBInspectable open var rasterizationScale: CGFloat {
        get {
            return layer.rasterizationScale
        }
        set {
            layer.rasterizationScale = newValue
        }
    }
}

extension UIView {
    
    /// The radius to use when drawing rounded corners for the layer’s background. Animatable.
    ///
    /// Setting the radius to a value greater than `0.0` causes the layer to begin drawing rounded corners on its
    /// background. By default, the corner radius does not apply to the image in the layer’s contents property; it
    /// applies only to the background color and border of the layer. However, setting the masksToBounds property to
    /// true causes the content to be clipped to the rounded corners.
    ///
    /// The default value of this property is `0.0`.
    @IBInspectable open var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    /// Defines which of the four corners receives the masking when using
    /// `cornerRadius' property. Defaults to all four corners.
    @available(iOS 11.0, tvOS 11.0, *)
    open var maskedCorners: CACornerMask {
        get {
            return layer.maskedCorners
        }
        set {
            layer.maskedCorners = newValue
        }
    }
}

extension UIView {
    
    /// The width of the layer’s border. Animatable.
    ///
    /// When this value is greater than `0.0`, the layer draws a border using the current `borderColor` value. The
    /// border is drawn inset from the receiver’s bounds by the value specified in this property. It is composited
    /// above the receiver’s contents and sublayers and includes the effects of the `cornerRadius` property.
    ///
    /// The default value of this property is `0.0`.
    @IBInspectable open var borderWidth: CGFloat {
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
    @IBInspectable open var borderColor: UIColor? {
        get {
            return layer.borderColor.map(UIColor.init)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

extension UIView {
    
    /// The color of the layer’s shadow. Animatable.
    ///
    /// The default value of this property is an opaque black color.
    ///
    /// The value of this property is retained using the Core Foundation retain/release semantics. This behavior
    /// occurs despite the fact that the property declaration appears to use the default assign semantics for
    /// object retention.
    @IBInspectable open var shadowColor: UIColor? {
        get {
            return layer.shadowColor.map(UIColor.init)
        }
        set {
            layer.shadowColor = newValue?.cgColor
        }
    }
    
    /// The opacity of the layer’s shadow. Animatable.
    ///
    /// The value in this property must be in the range `0.0` (transparent) to `1.0` (opaque). The default
    /// value of this property is `0.0`.
    @IBInspectable open var shadowOpacity: Float {
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
    @IBInspectable open var shadowOffset: CGSize {
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
    @IBInspectable open var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    /// The shape of the layer’s shadow. Animatable.
    ///
    /// The default value of this property is `nil`, which causes the layer to use a standard shadow shape.
    /// If you specify a value for this property, the layer creates its shadow using the specified path instead
    /// of the layer’s composited alpha channel. The path you provide defines the outline of the shadow. It is
    /// filled using the non-zero winding rule and the current shadow color, opacity, and blur radius.
    ///
    /// Unlike most animatable properties, this property (as with all `CGPathRef` animatable properties) does not
    /// support implicit animation. However, the path object may be animated using any of the concrete subclasses
    /// of `CAPropertyAnimation`. Paths will interpolate as a linear blend of the "on-line" points; "off-line" points
    /// may be interpolated non-linearly (to preserve continuity of the curve's derivative). If the two paths have
    /// a different number of control points or segments, the results are undefined. If the path extends outside
    /// the layer bounds it will not automatically be clipped to the layer, only if the normal layer masking rules
    /// cause that.
    ///
    /// Specifying an explicit path usually improves rendering performance.
    ///
    /// The value of this property is retained using the Core Foundation retain/release semantics. This behavior
    /// occurs despite the fact that the property declaration appears to use the default assign semantics for
    /// object retention.
    open var shadowPath: CGPath? {
        get {
            return layer.shadowPath
        }
        set {
            layer.shadowPath = newValue
        }
    }
}

extension UIView {
    
    /// The layer’s position on the z axis. Animatable.
    ///
    /// The default value of this property is `0`. Changing the value of this property changes the the front-to-back
    /// ordering of layers onscreen. Higher values place this layer visually closer to the viewer than layers with
    /// lower values. This can affect the visibility of layers whose frame rectangles overlap.
    ///
    /// The value of this property is measured in points.
    @IBInspectable open var zPosition: CGFloat {
        get {
            return layer.zPosition
        }
        set {
            layer.zPosition = newValue
        }
    }
    
    /// Defines the anchor point of the layer's bounds rectangle. Animatable.
    ///
    /// You specify the value for this property using the unit coordinate space. The default value of this property
    /// is (0.5, 0.5), which represents the center of the layer’s bounds rectangle. All geometric manipulations to the
    /// view occur about the specified point. For example, applying a rotation transform to a layer with the default
    /// anchor point causes the layer to rotate around its center. Changing the anchor point to a different location
    /// would cause the layer to rotate around that new point.
    ///
    /// For more information about the relationship between the `frame`, `bounds`, `anchorPoint` and `position` properties,
    /// see Core Animation Programming Guide.
    @IBInspectable open var anchorPoint: CGPoint {
        get {
            return layer.anchorPoint
        }
        set {
            layer.anchorPoint = newValue
        }
    }
    
    /// The anchor point for the layer’s position along the z axis. Animatable.
    ///
    /// This property specifies the anchor point on the z axis around which geometric manipulations occur. The point is
    /// expressed as a distance (measured in points) along the z axis. The default value of this property is `0`.
    @IBInspectable open var anchorPointZ: CGFloat {
        get {
            return layer.anchorPointZ
        }
        set {
            layer.anchorPointZ = newValue
        }
    }
}

extension UIView {
    
    /// A Boolean indicating whether the layer displays its content when facing away from the viewer. Animatable.
    ///
    /// When the value in this property is `false`, the layer hides its content when it faces away from the viewer.
    /// The default value of this property is `true`.
    @IBInspectable open var isDoubleSided: Bool {
        get {
            return layer.isDoubleSided
        }
        set {
            layer.isDoubleSided = newValue
        }
    }
    
    /// A Boolean that indicates whether the geometry of the layer and its sublayers is flipped vertically.
    ///
    /// If the layer is providing the backing for a layer-backed view, the view is responsible for managing
    /// the value in this property. For standalone layers, this property controls whether geometry values for
    /// the layer are interpreted using the standard or flipped coordinate system. The value of this property
    /// does not affect the rendering of the layer’s content.
    ///
    /// The default value of this property is `false`.
    @IBInspectable open var isGeometryFlipped: Bool {
        get {
            return layer.isGeometryFlipped
        }
        set {
            layer.isGeometryFlipped = newValue
        }
    }
    
    /// A Boolean indicating whether the layer content is implicitly flipped when rendered.
    ///
    /// true if the layer contents are implicitly flipped when rendered or false if they are not.
    open var contentsAreFlipped: Bool {
        return layer.contentsAreFlipped()
    }
}

extension UIView {
    
    @available(iOS 11.0, tvOS 11.0, *)
    @IBInspectable open var ignoresInvertColors: Bool {
        get {
            return accessibilityIgnoresInvertColors
        }
        set {
            accessibilityIgnoresInvertColors = newValue
        }
    }
}

#if os(iOS)

extension UIButton {
    
    @available(iOS 13.4, macCatalyst 13.4, *)
    @IBInspectable open var enablePointerInteraction: Bool {
        get {
            return isPointerInteractionEnabled
        }
        set {
            isPointerInteractionEnabled = newValue
        }
    }
}

#endif
