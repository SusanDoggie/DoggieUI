//
//  UITouchGestureRecognizer.swift
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

open class UITouchGestureRecognizer: UIGestureRecognizer {
    
    private var tracked: [UITouch] = []
    
    private var _translation: CGPoint = CGPoint()
    private var _magnitude: CGFloat = 0
    private var _phase: CGFloat = 0
    
}

extension UITouchGestureRecognizer {
    
    open func setTranslation(_ translation: CGPoint, in view: UIView?) {
        let translation = self.location(in: view) - translation
        if let view = view {
            self._translation = view.convert(translation, to: nil)
        } else {
            self._translation = translation
        }
    }
    
    open func translation(in view: UIView?) -> CGPoint {
        let _translation: CGPoint
        if let view = view {
            _translation = view.convert(self._translation, from: nil)
        } else {
            _translation = self._translation
        }
        return self.location(in: view) - _translation
    }
    
    open var scale: CGFloat {
        get {
            let diff = tracked[1].location(in: nil) - tracked[0].location(in: nil)
            return diff.magnitude / _magnitude
        }
        set {
            let diff = tracked[1].location(in: nil) - tracked[0].location(in: nil)
            _magnitude = diff.magnitude / newValue
        }
    }
    
    open var rotation: CGFloat {
        get {
            let diff = tracked[1].location(in: nil) - tracked[0].location(in: nil)
            return diff.phase - _phase
        }
        set {
            let diff = tracked[1].location(in: nil) - tracked[0].location(in: nil)
            _phase = diff.phase - newValue
        }
    }
}

extension UITouchGestureRecognizer {
    
    open override func location(ofTouch touchIndex: Int, in view: UIView?) -> CGPoint {
        return tracked[touchIndex].location(in: view)
    }
}

extension UITouchGestureRecognizer {
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        
        tracked.append(contentsOf: touches.subtracting(tracked))
        
        if state == .possible && touches.count >= 2 {
            scale = 1
            rotation = 0
            state = .began
        }
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        guard self.tracked.count >= 2 else { return }
        state = .changed
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        guard self.tracked.count >= 2 else { return }
        state = .ended
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .cancelled
    }
    
    open override func reset() {
        self.tracked.removeAll()
    }
}

open class UIShortTouchGestureRecognizer: UITouchGestureRecognizer {
    
    open var delay = 0.1
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        
        super.touchesBegan(touches, with: event)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            
            if self.state == UIGestureRecognizer.State.possible {
                self.state = UIGestureRecognizer.State.failed
            }
        }
    }
}
