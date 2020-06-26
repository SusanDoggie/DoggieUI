//
//  UIGestureRecognizer.swift
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
import SpriteKit

extension UIGestureRecognizer {
    
    open func location(in scene: SKScene) -> CGPoint {
        guard let view = scene.view else { return CGPoint() }
        return view.convert(self.location(in: view), to: scene)
    }
    
    open func location(ofTouch touchIndex: Int, in scene: SKScene) -> CGPoint {
        guard let view = scene.view else { return CGPoint() }
        return view.convert(self.location(ofTouch: touchIndex, in: view), to: scene)
    }
}
extension UIPanGestureRecognizer {
    
    open func translation(in scene: SKScene) -> CGPoint {
        guard let view = scene.view else { return CGPoint() }
        return view.convert(self.translation(in: view), to: scene)
    }
    
    open func setTranslation(_ translation: CGPoint, in scene: SKScene) {
        guard let view = scene.view else { return }
        self.setTranslation(view.convert(translation, from: scene), in: view)
    }
}
