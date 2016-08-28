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

@IBDesignable public class SDItemSelector : UIView {
    
    private var swappageView: SDSwipeView
    private var pageControl = UIPageControl()
    
    public weak var delegate: SDItemSelectorDelegate? {
        didSet {
            reloadData()
        }
    }
    
    private var _cache: [UIView?] = []
    
    @IBInspectable public var bounces: Bool {
        get {
            return swappageView.bounces
        }
        set {
            swappageView.bounces = newValue
        }
    }
    
    @IBInspectable public var swapEnabled : Bool {
        get {
            return swappageView.swapEnabled
        }
        set {
            swappageView.swapEnabled = newValue
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
            return swappageView.index
        }
        set {
            if swappageView.index != newValue {
                swappageView.index = newValue
                pageControl.currentPage = newValue
                swappageView.reload()
                if newValue < numberOfPages {
                    delegate?.itemSelector(self, didDisplayingView: self.itemForIndex(index: newValue), forIndex: newValue)
                }
            }
        }
    }
    
    private func cleanCache() {
        for item in _cache where item?.superview != nil {
            item?.removeFromSuperview()
        }
        _cache = [UIView?](repeatedValue: nil, count: numberOfPages)
    }
    
    public private(set) var numberOfPages: Int {
        get {
            return pageControl.numberOfPages
        }
        set {
            if pageControl.numberOfPages != newValue {
                pageControl.numberOfPages = newValue
                if pageControl.currentPage >= newValue {
                    currentPage = max(0, newValue - 1)
                }
                self.cleanCache()
            }
        }
    }
    
    public func viewForIndex(index: Int) -> UIView? {
        if index < numberOfPages {
            if _cache[index] == nil {
                _cache[index] = delegate?.itemSelector(_ itemSelector: self, viewForItemInIndex: index)
            }
            return _cache[index]
        }
        return nil
    }
    
    private func itemForIndex(index: Int) -> UIView {
        return self.viewForIndex(index: index) ?? UIView()
    }
    
    public func reloadData() {
        numberOfPages = delegate?.numberOfPagesInItemSelector(_ itemSelector: self) ?? 0
        self.cleanCache()
        swappageView.reload()
    }
    
    public override init(frame: CGRect) {
        swappageView = SDSwipeView()
        super.init(frame: frame)
        self.constructView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        swappageView = SDSwipeView()
        super.init(coder: aDecoder)
        self.constructView()
    }
    
    private func constructView() {
        
        swappageView.delegate = self
        
        self.addSubview(swappageView)
        self.addSubview(pageControl)
        
        swappageView.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([
            NSLayoutConstraint(item: pageControl, attribute: .Bottom, relatedBy: .Equal, toItem: swappageView, attribute: .Bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: pageControl, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)])
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[content]|", options: [], metrics: nil, views: ["content": swappageView]))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[content]|", options: [], metrics: nil, views: ["content": swappageView]))
    }
}

extension SDItemSelector : SDSwipeViewDelegate {
    
    public func swipeView(_ swipeView: SDSwipeView, viewForItemInIndex index: Int) -> UIView? {
        
        if swappageView === self.swappageView {
            if (0..<numberOfPages).contains(index) {
                return viewForIndex(index) ?? UIView()
            }
        }
        return nil
    }
    
    public func swipeView(_ swipeView: SDSwipeView, didDisplayingView view: UIView) {
        
        if swappageView === self.swappageView {
            pageControl.currentPage = swappageView.index
            delegate?.itemSelector(self, didDisplayingView: view, forIndex: swappageView.index)
        }
    }
}

public protocol SDItemSelectorDelegate : class {
    
    func numberOfPagesInItemSelector(_ itemSelector: SDItemSelector) -> Int
    
    func itemSelector(_ itemSelector: SDItemSelector, viewForItemInIndex index: Int) -> UIView?
    
    func itemSelector(_ itemSelector: SDItemSelector, didDisplayingView view: UIView, forIndex index: Int)
}

public extension SDItemSelectorDelegate {
    
    func itemSelector(_ itemSelector: SDItemSelector, didDisplayingView view: UIView, forIndex index: Int) {
        // do nothing
    }
}
