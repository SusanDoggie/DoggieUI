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
            value = max(minValue, min(maxValue, value))
            updateThumbViewPosition()
        }
    }
    
    @IBInspectable public var minTrackImage: UIImage? = nil {
        didSet {
            updateLayerFrames()
        }
    }
    @IBInspectable public var maxTrackImage: UIImage? = nil {
        didSet {
            updateLayerFrames()
        }
    }
    
    @IBInspectable public var trackImage: UIImage? = nil {
        didSet {
            updateTrackView()
        }
    }
    @IBInspectable public var trackTintColor: UIColor = UIColor.lightGray {
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
                trackCornerRadius = 0.5 * min(trackWidth, trackHeight)
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
    @IBInspectable public var thumbTintColor: UIColor = UIColor.black {
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
                thumbCornerRadius = 0.5 * min(thumbWidth, thumbHeight)
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
            return bounds.width - (minTrackImage?.size.width ?? 0) - (maxTrackImage?.size.width ?? 0)
        }
        if trackImage == nil {
            return trackThickness
        }
        return trackImage!.size.width
    }
    private var trackHeight : CGFloat {
        if !isHorizontal {
            return bounds.height - (minTrackImage?.size.height ?? 0) - (maxTrackImage?.size.height ?? 0)
        }
        if trackImage == nil {
            return trackThickness
        }
        return trackImage!.size.height
    }
    
    private func updateMinTrackView() {
        minTrackView.image = minTrackImage
        if let minTrackImage = minTrackImage {
            if isHorizontal {
                minTrackView.frame = CGRect(origin: CGPoint(x: 0.0, y: 0.5 * (bounds.height - minTrackImage.size.height)), size: minTrackImage.size)
            } else {
                minTrackView.frame = CGRect(origin: CGPoint(x: 0.5 * (bounds.width - minTrackImage.size.width), y: 0.0), size: minTrackImage.size)
            }
        }
    }
    private func updateMaxTrackView() {
        maxTrackView.image = maxTrackImage
        if let maxTrackImage = maxTrackImage {
            if isHorizontal {
                maxTrackView.frame = CGRect(origin: CGPoint(x: bounds.width - maxTrackImage.size.width, y: 0.5 * (bounds.height - maxTrackImage.size.height)), size: maxTrackImage.size)
            } else {
                maxTrackView.frame = CGRect(origin: CGPoint(x: 0.5 * (bounds.width - maxTrackImage.size.width), y: bounds.height - maxTrackImage.size.height), size: maxTrackImage.size)
            }
        }
    }
    private func updateTrackView() {
        trackView.image = trackImage
        if trackImage != nil {
            trackView.backgroundColor = UIColor.clear
        } else {
            trackView.backgroundColor = trackTintColor
        }
        if isHorizontal {
            trackView.frame.origin = CGPoint(x: minTrackImage?.size.width ?? 0, y: 0.5 * (bounds.height - trackHeight))
        } else {
            trackView.frame.origin = CGPoint(x: 0.5 * (bounds.width - trackWidth), y: minTrackImage?.size.width ?? 0)
        }
        trackView.frame.size = CGSize(width: trackWidth, height: trackHeight)
        if trackImage == nil && minTrackImage == nil && maxTrackImage == nil {
            trackView.cornerRadius = trackCornerRadius
        } else {
            trackView.cornerRadius = 0
        }
    }
    private func updateThumbView() {
        thumbView.image = thumbImage
        thumbView.highlightedImage = thumbHighlightedImage
        if thumbImage != nil {
            thumbView.backgroundColor = UIColor.clear
            thumbView.cornerRadius = 0.0
        } else {
            thumbView.backgroundColor = thumbTintColor
            thumbView.cornerRadius = thumbCornerRadius
        }
        updateThumbViewPosition()
        thumbView.frame.size = CGSize(width: thumbWidth, height: thumbHeight)
    }
    private func updateThumbViewPosition() {
        let t = (value - minValue) / (maxValue - minValue)
        if isHorizontal {
            if minTrackImage == nil && maxTrackImage == nil {
                let thumbCenter = (trackWidth - thumbWidth) * CGFloat(t)
                thumbView.frame.origin = CGPoint(x: thumbCenter, y: 0.5 * (bounds.height - thumbHeight))
            } else {
                let thumbCenter = trackWidth * CGFloat(t) + minTrackImage!.size.width
                thumbView.frame.origin = CGPoint(x: thumbCenter - 0.5 * thumbWidth, y: 0.5 * (bounds.height - thumbHeight))
            }
        } else {
            if minTrackImage == nil && maxTrackImage == nil {
                let thumbCenter = (trackHeight - thumbHeight) * CGFloat(1 - t)
                thumbView.frame.origin = CGPoint(x: 0.5 * (bounds.width - thumbWidth), y: thumbCenter)
            } else {
                let thumbCenter = trackHeight * CGFloat(1 - t) + minTrackImage!.size.height
                thumbView.frame.origin = CGPoint(x: 0.5 * (bounds.width - thumbWidth), y: thumbCenter - 0.5 * thumbHeight)
            }
        }
    }
    
    private func updateLayerFrames() {
        updateMinTrackView()
        updateMaxTrackView()
        updateTrackView()
        updateThumbView()
    }
    
    private func locateAndUpdateValue(location: CGPoint) {
        if isHorizontal {
            if minTrackImage == nil && maxTrackImage == nil {
                let s = (location.x + 0.5 * thumbWidth) / (trackWidth - thumbWidth)
                self.value = Double(s) * (maxValue - minValue) + minValue
            } else {
                let s = (location.x - minTrackImage!.size.width) / trackWidth
                self.value = Double(s) * (maxValue - minValue) + minValue
            }
        } else {
            if minTrackImage == nil && maxTrackImage == nil {
                let s = (location.y + 0.5 * thumbHeight) / (trackHeight - thumbHeight)
                self.value = Double(1 - s) * (maxValue - minValue) + minValue
            } else {
                let s = (location.y - minTrackImage!.size.height) / trackHeight
                self.value = Double(1 - s) * (maxValue - minValue) + minValue
            }
        }
        self.sendActions(for: .valueChanged)
    }
    
    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        let minSize = min(bounds.width, bounds.height)
        let hitTestMinSize = CGSize(width: minSize, height: minSize)
        
        let thumbViewHitBox = thumbView.frame.union(CGRect(origin: thumbView.frame.origin, size: hitTestMinSize))
        let thumbViewHitBoxCenterOffsetX = thumbViewHitBox.midX - thumbView.frame.midX
        let thumbViewHitBoxCenterOffsetY = thumbViewHitBox.midY - thumbView.frame.midY
        
        if thumbViewHitBox.offsetBy(dx: -thumbViewHitBoxCenterOffsetX, dy: -thumbViewHitBoxCenterOffsetY).contains(location) {
            thumbView.isHighlighted = true
            locateAndUpdateValue(location: location)
        } else if trackTouchRespond {
            let trackViewHitBox = trackView.frame.union(CGRect(origin: trackView.frame.origin, size: hitTestMinSize))
            let trackViewHitBoxCenterOffsetX = trackViewHitBox.midX - trackView.frame.midX
            let trackViewHitBoxCenterOffsetY = trackViewHitBox.midY - trackView.frame.midY
            if trackViewHitBox.offsetBy(dx: -trackViewHitBoxCenterOffsetX, dy: -trackViewHitBoxCenterOffsetY).contains(location) {
                thumbView.isHighlighted = true
                locateAndUpdateValue(location: location)
            }
        }
        
        return thumbView.isHighlighted
    }
    public override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        locateAndUpdateValue(location: touch.location(in: self))
        return true
    }
    public override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        if touch != nil {
            locateAndUpdateValue(location: touch!.location(in: self))
            thumbView.isHighlighted = false
        }
    }
}
