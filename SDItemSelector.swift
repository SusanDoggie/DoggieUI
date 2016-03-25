//
//  SDItemSelector.swift
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

@IBDesignable public class SDItemSelector : UIControl {
    
    private var pan: UIPanGestureRecognizer!
    
    private var contentView: UIView
    private var pageControl = UIPageControl()
    
    public weak var delegate: SDItemSelectorDelegate?
    
    private var _cache: [UIView?] = []
    
    @IBInspectable public var pageControlInside: Bool = true {
        didSet {
            if pageControlInside {
                NSLayoutConstraint.deactivateConstraints(outside_constraints)
                NSLayoutConstraint.activateConstraints(inside_constraints)
            } else {
                NSLayoutConstraint.deactivateConstraints(inside_constraints)
                NSLayoutConstraint.activateConstraints(outside_constraints)
            }
        }
    }
    
    @IBInspectable public var pageIndicatorTintColor: UIColor? {
        get {
            return pageControl.pageIndicatorTintColor
        }
        set {
            pageControl.pageIndicatorTintColor = newValue
        }
    }
    @IBInspectable public var currentPageIndicatorTintColor: UIColor? {
        get {
            return pageControl.currentPageIndicatorTintColor
        }
        set {
            pageControl.currentPageIndicatorTintColor = newValue
        }
    }
    
    public private(set) var currentPage: Int {
        get {
            return pageControl.currentPage
        }
        set {
            pageControl.currentPage = newValue
            delegate?.itemSelector(self, didDisplayingView: self.itemForIndex(newValue), forIndex: newValue)
        }
    }
    
    private func cleanCache() {
        for item in _cache where item?.superview != nil {
            item?.removeFromSuperview()
        }
        _cache = [UIView?](count: numberOfPages, repeatedValue: nil)
    }
    
    public private(set) var numberOfPages: Int {
        get {
            return pageControl.numberOfPages
        }
        set {
            if pageControl.numberOfPages != newValue {
                if pageControl.currentPage >= newValue {
                    pageControl.currentPage = newValue - 1
                }
                pageControl.numberOfPages = newValue
                self.cleanCache()
            }
        }
    }
    
    public func viewForIndex(index: Int) -> UIView? {
        if _cache[index] == nil {
            _cache[index] = delegate?.itemSelector(self, viewForItemInIndex: index)
        }
        return _cache[index]
    }
    
    private func itemForIndex(index: Int) -> UIView {
        return self.viewForIndex(index) ?? UIView()
    }
    
    public func reloadData() {
        numberOfPages = delegate?.numberOfPagesInItemSelector(self) ?? 0
        self.cleanCache()
        if self.numberOfPages != 0 {
            let current = self.itemForIndex(self.currentPage)
            current.frame = self.contentView.frame
            if current.superview == nil {
                self.contentView.addSubview(current)
            }
            current.hidden = false
            delegate?.itemSelector(self, didDisplayingView: current, forIndex: self.currentPage)
        }
    }
    
    private var inside_constraints: [NSLayoutConstraint] = []
    private var outside_constraints: [NSLayoutConstraint] = []
    
    public override init(frame: CGRect) {
        contentView = UIView()
        super.init(frame: frame)
        
        self.addSubview(contentView)
        self.addSubview(pageControl)
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        if pageControlInside {
            inside_constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[content]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["content": contentView])
            inside_constraints.append(NSLayoutConstraint(item: pageControl, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1, constant: 0))
            NSLayoutConstraint.activateConstraints(inside_constraints)
        } else {
            outside_constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[content][page]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["content": contentView, "page": pageControl])
            NSLayoutConstraint.activateConstraints(outside_constraints)
        }
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[content]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["content": contentView]))
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint(item: pageControl, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)])
        
        pan = UIPanGestureRecognizer(target: self, action: #selector(SDItemSelector.handlePan(_:)))
        pan.delegate = self
        self.addGestureRecognizer(pan)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        contentView = UIView()
        super.init(coder: aDecoder)
        
        self.addSubview(pageControl)
        self.addSubview(contentView)
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        if pageControlInside {
            inside_constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[content]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["content": contentView])
            inside_constraints.append(NSLayoutConstraint(item: pageControl, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1, constant: 0))
            NSLayoutConstraint.activateConstraints(inside_constraints)
        } else {
            outside_constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[content][page]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["content": contentView, "page": pageControl])
            NSLayoutConstraint.activateConstraints(outside_constraints)
        }
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[content]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["content": contentView]))
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint(item: pageControl, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)])
        
        pan = UIPanGestureRecognizer(target: self, action: #selector(SDItemSelector.handlePan(_:)))
        pan.maximumNumberOfTouches = 1
        pan.delegate = self
        self.addGestureRecognizer(pan)
    }
    
    public override func layoutSubviews() {
        self.numberOfPages = delegate?.numberOfPagesInItemSelector(self) ?? 0
        super.layoutSubviews()
        
        if self.numberOfPages != 0 {
            let current = self.itemForIndex(self.currentPage)
            current.frame = self.contentView.frame
            if current.superview == nil {
                self.contentView.addSubview(current)
            }
            current.hidden = false
            delegate?.itemSelector(self, didDisplayingView: current, forIndex: self.currentPage)
        }
    }
}

extension SDItemSelector : UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        
        if pan === gestureRecognizer {
            if self.numberOfPages < 2 {
                return false
            }
            return CGRectContainsPoint(contentView.frame, touch.locationInView(self))
        }
        return true
    }
    
    public override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if pan === gestureRecognizer {
            let velocity = pan.velocityInView(self)
            return abs(velocity.x) > abs(velocity.y)
        }
        return true
    }
    
    private func cancelAnimate() {
        self.layer.removeAllAnimations()
        let current = self.itemForIndex(self.currentPage)
        if current.frame.origin.x == -self.contentView.frame.width {
            self.currentPage = (self.currentPage + 1) % self.numberOfPages
        } else if current.frame.origin.x == self.contentView.frame.width {
            self.currentPage = (self.currentPage + self.numberOfPages - 1) % self.numberOfPages
        }
    }
    
    private func nextViewIndex(sender: UIPanGestureRecognizer) -> Int {
        if sender.translationInView(self).x < 0 {
            return (self.currentPage + 1) % self.numberOfPages
        } else {
            return (self.currentPage + self.numberOfPages - 1) % self.numberOfPages
        }
    }
    
    func handlePan(sender: UIPanGestureRecognizer) {
        
        if sender.state == .Began {
            self.cancelAnimate()
            sender.setTranslation(CGPoint(x: self.itemForIndex(self.currentPage).frame.origin.x, y: sender.translationInView(self).y), inView: self)
        }
        
        let translation = sender.translationInView(self)
        let velocity = sender.velocityInView(self)
        
        let nextIndex = self.nextViewIndex(sender)
        
        for idx in 0..<self.numberOfPages {
            self._cache[idx]?.hidden = idx != nextIndex && idx != self.currentPage
        }
        
        let next = self.itemForIndex(nextIndex)
        next.frame = self.contentView.frame
        if next.superview == nil {
            self.contentView.addSubview(next)
        }
        
        let current = self.itemForIndex(self.currentPage)
        
        current.frame.origin.x = translation.x
        if translation.x < 0 {
            next.frame.origin.x = translation.x + self.contentView.frame.width
        } else {
            next.frame.origin.x = translation.x - self.contentView.frame.width
        }
        
        if sender.state == .Ended {
            
            if translation.x < 0 {
                
                if abs(velocity.x) < 20 {
                    
                    if abs(translation.x) > self.contentView.frame.width / 2 {
                        
                        UIView.animateWithDuration(0.3, animations: {
                            
                            next.frame.origin.x = 0
                            current.frame.origin.x = -self.contentView.frame.width
                            }, completion: { _ in
                                self.currentPage = nextIndex
                        })
                    } else {
                        
                        UIView.animateWithDuration(0.3, animations: {
                            
                            next.frame.origin.x = self.contentView.frame.width
                            current.frame.origin.x = 0
                            }, completion: nil)
                    }
                    
                } else if velocity.x < 0 {
                    
                    UIView.animateWithDuration(0.3, animations: {
                        
                        next.frame.origin.x = 0
                        current.frame.origin.x = -self.contentView.frame.width
                        }, completion: { _ in
                            self.currentPage = nextIndex
                    })
                } else {
                    
                    UIView.animateWithDuration(0.3, animations: {
                        
                        next.frame.origin.x = self.contentView.frame.width
                        current.frame.origin.x = 0
                        }, completion: nil)
                }
            } else {
                
                
                if abs(velocity.x) < 20 {
                    
                    if abs(translation.x) > self.contentView.frame.width / 2 {
                        
                        UIView.animateWithDuration(0.3, animations: {
                            
                            next.frame.origin.x = 0
                            current.frame.origin.x = self.contentView.frame.width
                            }, completion: { _ in
                                self.currentPage = nextIndex
                        })
                    } else {
                        
                        UIView.animateWithDuration(0.3, animations: {
                            
                            next.frame.origin.x = -self.contentView.frame.width
                            current.frame.origin.x = 0
                            }, completion: nil)
                    }
                    
                } else if velocity.x > 0 {
                    
                    UIView.animateWithDuration(0.3, animations: {
                        
                        next.frame.origin.x = 0
                        current.frame.origin.x = self.contentView.frame.width
                        }, completion: { _ in
                            self.currentPage = nextIndex
                    })
                } else {
                    
                    UIView.animateWithDuration(0.3, animations: {
                        
                        next.frame.origin.x = -self.contentView.frame.width
                        current.frame.origin.x = 0
                        }, completion: nil)
                }
            }
        }
    }
}

public protocol SDItemSelectorDelegate : class {
    
    func numberOfPagesInItemSelector(itemSelector: SDItemSelector) -> Int
    
    func itemSelector(itemSelector: SDItemSelector, viewForItemInIndex index: Int) -> UIView?
    
    func itemSelector(itemSelector: SDItemSelector, didDisplayingView view: UIView, forIndex index: Int)
}
