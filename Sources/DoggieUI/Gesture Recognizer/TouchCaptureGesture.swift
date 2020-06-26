//
//  TouchCaptureGesture.swift
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
import UIKit.UIGestureRecognizerSubclass

@available(iOS 9.1, tvOS 9.1, *)
open class TouchCaptureGesture: UIGestureRecognizer {
    
    private var tracked: UITouch?
    
    private var _touches: [Touch] = []
    
    public private(set) var predictedTouches: [Touch] = []
    
    open var touches: [Touch] {
        
        let min_force = self._touches.lazy.compactMap { $0.force > 0 ? $0.force : nil }.min() ?? 1
        var touches = self._touches
        
        for index in touches.indices {
            touches[index].force = max(touches[index].force, min_force)
        }
        
        return touches
    }
    
    private func update(_ touches: Set<UITouch>, with event: UIEvent) {
        
        guard let tracked = self.tracked, touches.contains(tracked) else { return }
        
        if let _touches = event.coalescedTouches(for: tracked) {
            self._touches.append(contentsOf: _touches.map { Touch(for: $0) })
        } else {
            self._touches.append(Touch(for: tracked))
        }
        
        if let _touches = event.predictedTouches(for: tracked) {
            self.predictedTouches = _touches.map { Touch(for: $0) }
        }
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        
        if touches.count != 1 {
            self.state = .failed
        }
        
        if self.tracked == nil, let firstTouch = touches.first {
            self.tracked = firstTouch
            self.update(touches, with: event)
        }
        
        for touch in touches where touch != self.tracked {
            self.ignore(touch, for: event)
        }
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        guard state == .possible || state == .began || state == .changed else { return }
        self.update(touches, with: event)
        state = state == .possible ? .began : .changed
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        self.update(touches, with: event)
        state = state == .possible ? .failed : .ended
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        self._touches.removeAll()
        self.tracked = nil
        state = .cancelled
    }
    
    open override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
        
        let touch_properties: [UITouch.Properties] = [.altitude, .azimuth, .force, .location]
        
        for touch in touches {
            
            guard let estimationUpdateIndex = touch.estimationUpdateIndex else { continue }
            guard let index = self._touches.firstIndex(where: { $0.estimationUpdateIndex?.isEqual(to: estimationUpdateIndex) == true }) else { continue }
            
            for property in touch_properties {
                
                guard self._touches[index].estimatedPropertiesExpectingUpdates.contains(property) else { continue }
                
                switch property {
                case .force: self._touches[index].force = touch.force
                case .azimuth: self._touches[index].azimuthAngle = touch.azimuthAngle(in: touch.view)
                case .altitude: self._touches[index].altitudeAngle = touch.altitudeAngle
                case .location:
                    self._touches[index]._location = touch.location(in: nil)
                    self._touches[index]._preciseLocation = touch.preciseLocation(in: nil)
                default: break
                }
            }
            
            self._touches[index].estimatedProperties = touch.estimatedProperties
            self._touches[index].estimatedPropertiesExpectingUpdates = touch.estimatedPropertiesExpectingUpdates
        }
    }
    
    open override func reset() {
        self._touches.removeAll()
        self.tracked = nil
    }
}

@available(iOS 9.1, tvOS 9.1, *)
extension TouchCaptureGesture {
    
    public struct Touch {
        
        public var type: UITouch.TouchType
        
        public var view: UIView?
        
        public var window: UIWindow?
        
        public var timestamp: TimeInterval
        
        fileprivate var _location: CGPoint
        
        fileprivate var _preciseLocation: CGPoint
        
        public var majorRadius: CGFloat
        
        public var majorRadiusTolerance: CGFloat
        
        public var force: CGFloat
        
        public var maximumPossibleForce: CGFloat
        
        public var altitudeAngle: CGFloat
        
        public var azimuthAngle: CGFloat
        
        public var estimatedProperties: UITouch.Properties
        
        public var estimatedPropertiesExpectingUpdates: UITouch.Properties
        
        public var estimationUpdateIndex: NSNumber?
        
        fileprivate init(for touch: UITouch) {
            self.type = touch.type
            self.view = touch.view
            self.window = touch.window
            self.timestamp = touch.timestamp
            self._location = touch.location(in: nil)
            self._preciseLocation = touch.preciseLocation(in: nil)
            self.majorRadius = touch.majorRadius
            self.majorRadiusTolerance = touch.majorRadiusTolerance
            self.force = touch.force
            self.maximumPossibleForce = touch.maximumPossibleForce
            self.altitudeAngle = touch.altitudeAngle
            self.azimuthAngle = touch.azimuthAngle(in: touch.view)
            self.estimatedProperties = touch.estimatedProperties
            self.estimatedPropertiesExpectingUpdates = touch.estimatedPropertiesExpectingUpdates
            self.estimationUpdateIndex = touch.estimationUpdateIndex
        }
        
        public func location(in view: UIView?) -> CGPoint {
            return view?.convert(_location, from: nil) ?? _location
        }
        
        public func preciseLocation(in view: UIView?) -> CGPoint {
            return view?.convert(_preciseLocation, from: nil) ?? _preciseLocation
        }
    }
    
}
