//
//  SDSlider.swift
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
import QuartzCore

@IBDesignable public class SDSlider : UIControl {
    
    @IBInspectable public var minValue: Double = 0.0 {
        didSet {
            updateLayerFrames()
        }
    }
    @IBInspectable public var maxValue: Double = 1.0 {
        didSet {
            updateLayerFrames()
        }
    }
    @IBInspectable public var value: Double = 0.5 {
        didSet {
            value = value.clamp(minValue...maxValue)
            updateThumbViewPosition()
        }
    }
    
    @IBInspectable public var minImage: UIImage? = nil {
        didSet {
            updateLayerFrames()
        }
    }
    @IBInspectable public var maxImage: UIImage? = nil {
        didSet {
            updateLayerFrames()
        }
    }
    
    @IBInspectable public var trackImage: UIImage? = nil {
        didSet {
            updateTrackView()
        }
    }
    @IBInspectable public var trackTintColor: UIColor = UIColor.lightGrayColor() {
        didSet {
            updateTrackView()
        }
    }
    @IBInspectable public var trackThickness: CGFloat = 2.0 {
        didSet {
            updateTrackView()
        }
    }
    @IBInspectable public var trackCornerRadius: CGFloat = 0.0 {
        didSet {
            if trackCornerRadius * 2.0 > trackWidth || trackCornerRadius * 2.0 > trackHeight {
                trackCornerRadius = min(trackWidth, trackHeight) / 2.0
            }
            updateTrackView()
        }
    }
    @IBInspectable public var trackTouchRespond: Bool = false
    
    @IBInspectable public var thumbImage: UIImage? = nil {
        didSet {
            updateThumbView()
        }
    }
    @IBInspectable public var thumbHighlightedImage: UIImage? = nil {
        didSet {
            updateThumbView()
        }
    }
    @IBInspectable public var thumbTintColor: UIColor = UIColor.blackColor() {
        didSet {
            updateThumbView()
        }
    }
    @IBInspectable public var thumbLength: CGFloat = 18.0 {
        didSet {
            updateThumbView()
        }
    }
    @IBInspectable public var thumbThickness: CGFloat = 2.0 {
        didSet {
            updateThumbView()
        }
    }
    @IBInspectable public var thumbCornerRadius: CGFloat = 0.0 {
        didSet {
            if thumbCornerRadius * 2.0 > thumbWidth || thumbCornerRadius * 2.0 > thumbHeight {
                thumbCornerRadius = min(thumbWidth, thumbHeight) / 2.0
            }
            updateThumbView()
        }
    }
    
    private let minTrackView = UIImageView()
    private let maxTrackView = UIImageView()
    private let trackView = UIImageView()
    private let thumbView = UIImageView()
    
    public override var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(minTrackView)
        self.addSubview(maxTrackView)
        self.addSubview(trackView)
        self.addSubview(thumbView)
        self.updateLayerFrames()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addSubview(minTrackView)
        self.addSubview(maxTrackView)
        self.addSubview(trackView)
        self.addSubview(thumbView)
        self.updateLayerFrames()
    }
    
    public override func layoutSubviews() {
        self.updateLayerFrames()
    }
    
}

extension SDSlider {
    
    private var isHorizontal: Bool {
        return bounds.height < bounds.width
    }
    
    private var thumbWidth : CGFloat {
        if thumbImage == nil {
            if isHorizontal {
                return thumbThickness
            }
            return thumbLength
        }
        return thumbImage!.size.width
    }
    private var thumbHeight : CGFloat {
        if thumbImage == nil {
            if isHorizontal {
                return thumbLength
            }
            return thumbThickness
        }
        return thumbImage!.size.height
    }
    private var trackWidth : CGFloat {
        if isHorizontal {
            return bounds.width - (minImage?.size.width ?? 0) - (maxImage?.size.width ?? 0)
        }
        if trackImage == nil {
            return trackThickness
        }
        return trackImage!.size.width
    }
    private var trackHeight : CGFloat {
        if !isHorizontal {
            return bounds.height - (minImage?.size.height ?? 0) - (maxImage?.size.height ?? 0)
        }
        if trackImage == nil {
            return trackThickness
        }
        return trackImage!.size.height
    }
    
    private func updateMinTrackView() {
        minTrackView.image = minImage
        if let minImage = minImage {
            if isHorizontal {
                minTrackView.frame = CGRect(origin: CGPoint(x: 0.0, y: (bounds.height - minImage.size.height) / 2.0), size: minImage.size)
            } else {
                minTrackView.frame = CGRect(origin: CGPoint(x: (bounds.width - minImage.size.width) / 2.0, y: 0.0), size: minImage.size)
            }
        }
    }
    private func updateMaxTrackView() {
        maxTrackView.image = maxImage
        if let maxImage = maxImage {
            if isHorizontal {
                maxTrackView.frame = CGRect(origin: CGPoint(x: bounds.width - maxImage.size.width, y: (bounds.height - maxImage.size.height) / 2.0), size: maxImage.size)
            } else {
                maxTrackView.frame = CGRect(origin: CGPoint(x: (bounds.width - maxImage.size.width) / 2.0, y: bounds.height - maxImage.size.height), size: maxImage.size)
            }
        }
    }
    private func updateTrackView() {
        trackView.image = trackImage
        if trackImage != nil {
            trackView.backgroundColor = UIColor.clearColor()
        } else {
            trackView.backgroundColor = trackTintColor
        }
        if isHorizontal {
            trackView.frame.origin = CGPoint(x: minImage?.size.width ?? 0, y: (bounds.height - trackHeight) / 2.0)
        } else {
            trackView.frame.origin = CGPoint(x: (bounds.width - trackWidth) / 2.0, y: minImage?.size.width ?? 0)
        }
        trackView.frame.size = CGSize(width: trackWidth, height: trackHeight)
        if trackImage == nil && minImage == nil && maxImage == nil {
            trackView.layer.cornerRadius = trackCornerRadius
        } else {
            trackView.layer.cornerRadius = 0
        }
    }
    private func updateThumbView() {
        thumbView.image = thumbImage
        thumbView.highlightedImage = thumbHighlightedImage
        if thumbImage != nil {
            thumbView.backgroundColor = UIColor.clearColor()
            thumbView.layer.cornerRadius = 0.0
        } else {
            thumbView.backgroundColor = thumbTintColor
            thumbView.layer.cornerRadius = thumbCornerRadius
        }
        updateThumbViewPosition()
        thumbView.frame.size = CGSize(width: thumbWidth, height: thumbHeight)
    }
    private func updateThumbViewPosition() {
        let t = (value - minValue) / (maxValue - minValue)
        if isHorizontal {
            if minImage == nil {
                let thumbCenter = (trackWidth - trackCornerRadius * 2.0) * CGFloat(t) + trackCornerRadius
                thumbView.frame.origin = CGPoint(x: thumbCenter - thumbWidth / 2.0, y: (bounds.height - thumbHeight) / 2.0)
            } else {
                let thumbCenter = trackWidth * CGFloat(t) + minImage!.size.width
                thumbView.frame.origin = CGPoint(x: thumbCenter - thumbWidth / 2.0, y: (bounds.height - thumbHeight) / 2.0)
            }
        } else {
            if minImage == nil {
                let thumbCenter = (trackHeight - trackCornerRadius * 2.0) * CGFloat(1 - t) + trackCornerRadius
                thumbView.frame.origin = CGPoint(x: (bounds.width - thumbWidth) / 2.0, y: thumbCenter - thumbHeight / 2.0)
            } else {
                let thumbCenter = trackHeight * CGFloat(t) + minImage!.size.height
                thumbView.frame.origin = CGPoint(x: (bounds.width - thumbWidth) / 2.0, y: thumbCenter - thumbHeight / 2.0)
            }
        }
    }
    
    private func updateLayerFrames() {
        updateMinTrackView()
        updateMaxTrackView()
        updateTrackView()
        updateThumbView()
    }
    
}

extension SDSlider {
    
    private func locateAndUpdateValue(location: CGPoint) {
        if isHorizontal {
            if minImage == nil {
                let s = (location.x - trackCornerRadius) / (trackWidth - trackCornerRadius * 2.0)
                self.value = Double(s) * (maxValue - minValue) + minValue
            } else {
                let s = (location.x - minImage!.size.width) / trackWidth
                self.value = Double(s) * (maxValue - minValue) + minValue
            }
        } else {
            if minImage == nil {
                let s = (location.y - trackCornerRadius) / (trackHeight - trackCornerRadius * 2.0)
                self.value = Double(1 - s) * (maxValue - minValue) + minValue
            } else {
                let s = (location.y - minImage!.size.height) / trackHeight
                self.value = Double(1 - s) * (maxValue - minValue) + minValue
            }
        }
        self.sendActionsForControlEvents(.ValueChanged)
    }
    
    public override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let location = touch.locationInView(self)
        
        let minSize = min(bounds.width, bounds.height)
        let hitTestMinSize = CGSize(width: minSize, height: minSize)
        
        let thumbViewHitBox = CGRectUnion(thumbView.frame, CGRect(origin: thumbView.frame.origin, size: hitTestMinSize))
        let thumbViewHitBoxCenterOffsetX = thumbViewHitBox.midX - thumbView.frame.midX
        let thumbViewHitBoxCenterOffsetY = thumbViewHitBox.midY - thumbView.frame.midY
        
        if CGRectContainsPoint(CGRectOffset(thumbViewHitBox, -thumbViewHitBoxCenterOffsetX, -thumbViewHitBoxCenterOffsetY), location) {
            thumbView.highlighted = true
            locateAndUpdateValue(location)
        } else if trackTouchRespond {
            let trackViewHitBox = CGRectUnion(trackView.frame, CGRect(origin: trackView.frame.origin, size: hitTestMinSize))
            let trackViewHitBoxCenterOffsetX = trackViewHitBox.midX - trackView.frame.midX
            let trackViewHitBoxCenterOffsetY = trackViewHitBox.midY - trackView.frame.midY
            if CGRectContainsPoint(CGRectOffset(trackViewHitBox, -trackViewHitBoxCenterOffsetX, -trackViewHitBoxCenterOffsetY), location) {
                thumbView.highlighted = true
                locateAndUpdateValue(location)
            }
        }
        
        return thumbView.highlighted
    }
    public override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        locateAndUpdateValue(touch.locationInView(self))
        return true
    }
    public override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        if touch != nil {
            locateAndUpdateValue(touch!.locationInView(self))
            thumbView.highlighted = false
        }
    }
}
