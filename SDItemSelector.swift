//
//  SDItemSelector.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2018 Susan Cheng. All rights reserved.
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

@IBDesignable open class SDItemSelector : UIView {
    
    fileprivate var swipeView: SDSwipeView
    fileprivate var pageControl = UIPageControl()
    
    open weak var delegate: SDItemSelectorDelegate? {
        didSet {
            reloadData()
        }
    }
    
    fileprivate var _cache: [UIView?] = []
    
    @IBInspectable open var bounces: Bool {
        get {
            return swipeView.bounces
        }
        set {
            swipeView.bounces = newValue
        }
    }
    
    @IBInspectable open var swapEnabled : Bool {
        get {
            return swipeView.swapEnabled
        }
        set {
            swipeView.swapEnabled = newValue
        }
    }
    
    @IBInspectable open var pageIndicatorTintColor: UIColor? {
        get {
            return pageControl.pageIndicatorTintColor
        }
        set {
            pageControl.pageIndicatorTintColor = newValue
        }
    }
    @IBInspectable open var currentPageIndicatorTintColor: UIColor? {
        get {
            return pageControl.currentPageIndicatorTintColor
        }
        set {
            pageControl.currentPageIndicatorTintColor = newValue
        }
    }
    
    open fileprivate(set) var currentPage: Int {
        get {
            return swipeView.index
        }
        set {
            if swipeView.index != newValue {
                swipeView.index = newValue
                pageControl.currentPage = newValue
                swipeView.reload()
                if newValue < numberOfPages {
                    delegate?.itemSelector(self, didDisplayingView: self.itemForIndex(newValue), forIndex: newValue)
                }
            }
        }
    }
    
    fileprivate func cleanCache() {
        for item in _cache where item?.superview != nil {
            item?.removeFromSuperview()
        }
        _cache = [UIView?](repeating: nil, count: numberOfPages)
    }
    
    open fileprivate(set) var numberOfPages: Int {
        get {
            return pageControl.numberOfPages
        }
        set {
            if pageControl.numberOfPages != newValue {
                pageControl.numberOfPages = newValue
                if pageControl.currentPage >= newValue {
                    currentPage = Swift.max(0, newValue - 1)
                }
                self.cleanCache()
            }
        }
    }
    
    public func viewForIndex(_ index: Int) -> UIView? {
        if index < numberOfPages {
            if _cache[index] == nil {
                _cache[index] = delegate?.itemSelector(self, viewForItemInIndex: index)
            }
            return _cache[index]
        }
        return nil
    }
    
    fileprivate func itemForIndex(_ index: Int) -> UIView {
        return self.viewForIndex(index) ?? UIView()
    }
    
    public func reloadData() {
        numberOfPages = delegate?.numberOfPagesInItemSelector(self) ?? 0
        self.cleanCache()
        swipeView.reload()
    }
    
    public override init(frame: CGRect) {
        swipeView = SDSwipeView()
        super.init(frame: frame)
        self.constructView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        swipeView = SDSwipeView()
        super.init(coder: aDecoder)
        self.constructView()
    }
    
    fileprivate func constructView() {
        
        swipeView.delegate = self
        
        self.addSubview(swipeView)
        self.addSubview(pageControl)
        
        swipeView.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: pageControl, attribute: .bottom, relatedBy: .equal, toItem: swipeView, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: pageControl, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)])
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[content]|", options: [], metrics: nil, views: ["content": swipeView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[content]|", options: [], metrics: nil, views: ["content": swipeView]))
    }
}

extension SDItemSelector : SDSwipeViewDelegate {
    
    public func swipeView(_ swipeView: SDSwipeView, viewForItemInIndex index: Int) -> UIView? {
        
        if swipeView === self.swipeView {
            if (0..<numberOfPages).contains(index) {
                return viewForIndex(index) ?? UIView()
            }
        }
        return nil
    }
    
    public func swipeView(_ swipeView: SDSwipeView, didDisplayingView view: UIView) {
        
        if swipeView === self.swipeView {
            pageControl.currentPage = swipeView.index
            delegate?.itemSelector(self, didDisplayingView: view, forIndex: swipeView.index)
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
