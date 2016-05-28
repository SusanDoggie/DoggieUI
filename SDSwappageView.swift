//
//  SDSwappageView.swift
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

public protocol SDSwappageViewDelegate : class {
    
    func swappageView(swappageView: SDSwappageView, viewForItemInIndex index: Int) -> UIView?
    
    func swappageView(swappageView: SDSwappageView, didDisplayingView view: UIView)
}

public class SDSwappageView: UIView {
    
    private let scrollView = UIScrollView()
    
    private let page_1 = UIView()
    private let page_2 = UIView()
    private let page_3 = UIView()
    
    public var index = 0
    
    private var left: UIView?
    private var right: UIView?
    
    public var current: UIView?
    
    private var scrolling = false
    private var jumpSwap : Int?
    
    public weak var delegate : SDSwappageViewDelegate? {
        didSet {
            reload()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.constructView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.constructView()
    }
    
    @IBInspectable public var bounces: Bool {
        get {
            return scrollView.bounces
        }
        set {
            scrollView.bounces = newValue
        }
    }
    
    @IBInspectable public var swapEnabled : Bool {
        get {
            return scrollView.scrollEnabled
        }
        set {
            scrollView.scrollEnabled = newValue
        }
    }
    
    private func constructView() {
        
        scrollView.pagingEnabled = true
        scrollView.directionalLockEnabled = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        
        scrollView.delegate = self
        
        self.addSubview(scrollView)
        
        page_1.clipsToBounds = true
        page_2.clipsToBounds = true
        page_3.clipsToBounds = true
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        page_1.translatesAutoresizingMaskIntoConstraints = false
        page_2.translatesAutoresizingMaskIntoConstraints = false
        page_3.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public func reload() {
        
        current = delegate?.swappageView(self, viewForItemInIndex: index)
        if current != nil {
            left = delegate?.swappageView(self, viewForItemInIndex: index - 1)
            right = delegate?.swappageView(self, viewForItemInIndex: index + 1)
        } else {
            left = nil
            right = nil
        }
        _layoutSubviews()
        if current != nil {
            delegate?.swappageView(self, didDisplayingView: current!)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        _layoutSubviews()
    }
    
    private func _layoutOnePage() {
        scrollView.addSubview(page_1)
        NSLayoutConstraint.activateConstraints([
            NSLayoutConstraint(item: page_1, attribute: .Width, relatedBy: .Equal, toItem: scrollView, attribute: .Width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: page_1, attribute: .Height, relatedBy: .Equal, toItem: scrollView, attribute: .Height, multiplier: 1, constant: 0)])
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[scroll]|", options: [], metrics: nil, views: ["scroll": scrollView]))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[scroll]|", options: [], metrics: nil, views: ["scroll": scrollView]))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[page]|", options: [], metrics: nil, views: ["page": page_1]))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[one]", options: [], metrics: nil, views: ["one": page_1]))
    }
    
    private func _layoutTwoPage() {
        scrollView.addSubview(page_1)
        scrollView.addSubview(page_2)
        NSLayoutConstraint.activateConstraints([
            NSLayoutConstraint(item: page_1, attribute: .Width, relatedBy: .Equal, toItem: scrollView, attribute: .Width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: page_1, attribute: .Height, relatedBy: .Equal, toItem: scrollView, attribute: .Height, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: page_2, attribute: .Width, relatedBy: .Equal, toItem: scrollView, attribute: .Width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: page_2, attribute: .Height, relatedBy: .Equal, toItem: scrollView, attribute: .Height, multiplier: 1, constant: 0)])
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[scroll]|", options: [], metrics: nil, views: ["scroll": scrollView]))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[scroll]|", options: [], metrics: nil, views: ["scroll": scrollView]))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[page]|", options: [], metrics: nil, views: ["page": page_1]))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[page]|", options: [], metrics: nil, views: ["page": page_2]))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[one][two]|", options: [], metrics: nil, views: ["one": page_1, "two": page_2]))
    }
    
    private func _layoutThreePage() {
        scrollView.addSubview(page_1)
        scrollView.addSubview(page_2)
        scrollView.addSubview(page_3)
        NSLayoutConstraint.activateConstraints([
            NSLayoutConstraint(item: page_1, attribute: .Width, relatedBy: .Equal, toItem: scrollView, attribute: .Width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: page_1, attribute: .Height, relatedBy: .Equal, toItem: scrollView, attribute: .Height, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: page_2, attribute: .Width, relatedBy: .Equal, toItem: scrollView, attribute: .Width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: page_2, attribute: .Height, relatedBy: .Equal, toItem: scrollView, attribute: .Height, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: page_3, attribute: .Width, relatedBy: .Equal, toItem: scrollView, attribute: .Width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: page_3, attribute: .Height, relatedBy: .Equal, toItem: scrollView, attribute: .Height, multiplier: 1, constant: 0)])
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[scroll]|", options: [], metrics: nil, views: ["scroll": scrollView]))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[scroll]|", options: [], metrics: nil, views: ["scroll": scrollView]))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[page]|", options: [], metrics: nil, views: ["page": page_1]))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[page]|", options: [], metrics: nil, views: ["page": page_2]))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[page]|", options: [], metrics: nil, views: ["page": page_3]))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[one][two][three]|", options: [], metrics: nil, views: ["one": page_1, "two": page_2, "three": page_3]))
    }
    
    private func _layoutSubviews() {
        
        for item in page_1.subviews {
            item.removeFromSuperview()
        }
        for item in page_2.subviews {
            item.removeFromSuperview()
        }
        for item in page_3.subviews {
            item.removeFromSuperview()
        }
        for item in scrollView.subviews {
            item.removeFromSuperview()
        }
        
        if current == nil {
            return
        }
        
        left = left ?? delegate?.swappageView(self, viewForItemInIndex: index - 1)
        right = right ?? delegate?.swappageView(self, viewForItemInIndex: index + 1)
        
        if left == nil && right == nil {
            _layoutOnePage()
            page_1.addSubview(current!)
            current!.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[current]|", options: [], metrics: nil, views: ["current": current!]))
            NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[current]|", options: [], metrics: nil, views: ["current": current!]))
            scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: scrollView.frame.width, height: scrollView.frame.height), animated: false)
        } else if left == nil {
            _layoutTwoPage()
            page_1.addSubview(current!)
            page_2.addSubview(right!)
            current!.translatesAutoresizingMaskIntoConstraints = false
            right!.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[current]|", options: [], metrics: nil, views: ["current": current!]))
            NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[current]|", options: [], metrics: nil, views: ["current": current!]))
            NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[right]|", options: [], metrics: nil, views: ["right": right!]))
            NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[right]|", options: [], metrics: nil, views: ["right": right!]))
            scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: scrollView.frame.width, height: scrollView.frame.height), animated: false)
        } else if right == nil {
            _layoutTwoPage()
            page_1.addSubview(left!)
            page_2.addSubview(current!)
            left!.translatesAutoresizingMaskIntoConstraints = false
            current!.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[left]|", options: [], metrics: nil, views: ["left": left!]))
            NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[left]|", options: [], metrics: nil, views: ["left": left!]))
            NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[current]|", options: [], metrics: nil, views: ["current": current!]))
            NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[current]|", options: [], metrics: nil, views: ["current": current!]))
            scrollView.scrollRectToVisible(CGRect(x: scrollView.frame.width, y: 0, width: scrollView.frame.width, height: scrollView.frame.height), animated: false)
        } else {
            _layoutThreePage()
            page_1.addSubview(left!)
            page_2.addSubview(current!)
            page_3.addSubview(right!)
            left!.translatesAutoresizingMaskIntoConstraints = false
            current!.translatesAutoresizingMaskIntoConstraints = false
            right!.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[left]|", options: [], metrics: nil, views: ["left": left!]))
            NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[left]|", options: [], metrics: nil, views: ["left": left!]))
            NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[current]|", options: [], metrics: nil, views: ["current": current!]))
            NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[current]|", options: [], metrics: nil, views: ["current": current!]))
            NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[right]|", options: [], metrics: nil, views: ["right": right!]))
            NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[right]|", options: [], metrics: nil, views: ["right": right!]))
            scrollView.scrollRectToVisible(CGRect(x: scrollView.frame.width, y: 0, width: scrollView.frame.width, height: scrollView.frame.height), animated: false)
        }
    }
}

extension SDSwappageView {
    
    public func swapToView(index: Int, animated: Bool) {
        
        if self.index == index {
            return
        }
        
        if let jumpView = delegate?.swappageView(self, viewForItemInIndex: index) {
            if animated {
                if !scrolling && !scrollView.decelerating {
                    jumpSwap = index
                    scrolling = true
                    if index < self.index {
                        left = jumpView
                        _layoutSubviews()
                        scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: scrollView.frame.width, height: scrollView.frame.height), animated: true)
                    } else {
                        right = jumpView
                        _layoutSubviews()
                        if left == nil {
                            scrollView.scrollRectToVisible(CGRect(x: scrollView.frame.width, y: 0, width: scrollView.frame.width, height: scrollView.frame.height), animated: true)
                        } else {
                            scrollView.scrollRectToVisible(CGRect(x: 2 * scrollView.frame.width, y: 0, width: scrollView.frame.width, height: scrollView.frame.height), animated: true)
                        }
                    }
                }
            } else {
                jumpSwap = nil
                scrolling = false
                right = nil
                current = jumpView
                left = nil
                self.index = index
                _layoutSubviews()
                delegate?.swappageView(self, didDisplayingView: current!)
            }
        }
    }
    
    public func swapToLeft(animated: Bool) {
        
        if left != nil {
            if animated {
                if !scrolling && !scrollView.decelerating {
                    jumpSwap = nil
                    scrolling = true
                    scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: scrollView.frame.width, height: scrollView.frame.height), animated: true)
                }
            } else {
                jumpSwap = nil
                scrolling = false
                right = current
                current = left
                left = nil
                index -= 1
                _layoutSubviews()
                delegate?.swappageView(self, didDisplayingView: current!)
            }
        }
    }
    public func swapToRight(animated: Bool) {
        
        if right != nil {
            if animated {
                if !scrolling && !scrollView.decelerating {
                    jumpSwap = nil
                    scrolling = true
                    if left == nil {
                        scrollView.scrollRectToVisible(CGRect(x: scrollView.frame.width, y: 0, width: scrollView.frame.width, height: scrollView.frame.height), animated: true)
                    } else {
                        scrollView.scrollRectToVisible(CGRect(x: 2 * scrollView.frame.width, y: 0, width: scrollView.frame.width, height: scrollView.frame.height), animated: true)
                    }
                }
            } else {
                jumpSwap = nil
                scrolling = false
                left = current
                current = right
                right = nil
                index += 1
                _layoutSubviews()
                delegate?.swappageView(self, didDisplayingView: current!)
            }
        }
    }
}

extension SDSwappageView : UIScrollViewDelegate {
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        if scrollView === self.scrollView {
            endMoving()
        }
    }
    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        
        if scrollView === self.scrollView {
            endMoving()
            jumpSwap = nil
            scrolling = false
        }
    }
    
    private func endMoving() {
        let shift = lround(Double(scrollView.contentOffset.x / scrollView.frame.width))
        if shift == 0 && left != nil {
            right = jumpSwap == nil ? current : nil
            current = left
            left = nil
            if jumpSwap == nil {
                index -= 1
            } else {
                index = jumpSwap!
            }
            _layoutSubviews()
            delegate?.swappageView(self, didDisplayingView: current!)
        } else if ((left == nil && shift == 1) || (left != nil && shift == 2)) && right != nil {
            left = jumpSwap == nil ? current : nil
            current = right
            right = nil
            if jumpSwap == nil {
                index += 1
            } else {
                index = jumpSwap!
            }
            _layoutSubviews()
            delegate?.swappageView(self, didDisplayingView: current!)
        }
    }
}
