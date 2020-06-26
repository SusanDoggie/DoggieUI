//
//  SDPageView.swift
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

#if os(iOS)

import UIKit

@objc public protocol SDPageViewDataSource: AnyObject {
    
    @objc optional func numberOfPagesInPageView(_ pageView: SDPageView) -> Int
    
    func pageView(_ pageView: SDPageView, viewForItemInIndex index: Int) -> UIView?
}

@objc public protocol SDPageViewDelegate: AnyObject {
    
    @objc optional func pageView(_ pageView: SDPageView, didDisplayingView view: UIView)
}

open class SDPageView: UIView, UIScrollViewDelegate {
    
    fileprivate let scrollView = UIScrollView()
    fileprivate var pageControl = UIPageControl()
    
    fileprivate let page_1 = UIView()
    fileprivate let page_2 = UIView()
    fileprivate let page_3 = UIView()
    
    open var index = 0
    
    fileprivate var left: UIView?
    fileprivate var right: UIView?
    
    open var current: UIView?
    
    fileprivate var scrolling = false
    fileprivate var jumpSwap: Int?
    
    @IBOutlet open weak var dataSource: SDPageViewDataSource? {
        didSet {
            reloadData()
        }
    }
    
    @IBOutlet open weak var delegate: SDPageViewDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.constructView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.constructView()
    }
    
    @IBInspectable open var bounces: Bool {
        get {
            return scrollView.bounces
        }
        set {
            scrollView.bounces = newValue
        }
    }
    
    @IBInspectable open var swapEnabled: Bool {
        get {
            return scrollView.isScrollEnabled
        }
        set {
            scrollView.isScrollEnabled = newValue
        }
    }
    
    @IBInspectable open var pageControlEnabled: Bool {
        get {
            return !pageControl.isHidden
        }
        set {
            pageControl.isHidden = !newValue
        }
    }
    
    @IBInspectable open var pageControlBottomSpacing: CGFloat = 0.0 {
        didSet {
            _layoutPageControl()
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
    
    fileprivate func constructView() {
        
        scrollView.isPagingEnabled = true
        scrollView.isDirectionalLockEnabled = false
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
        
        pageControl.isHidden = true
        self.addSubview(pageControl)
        
        _layoutPageControl()
        pageControl.addTarget(self, action: #selector(pageControlValueChanged), for: .valueChanged)
    }
    
    fileprivate func _fetchPage(_ index: Int, numberOfPages: Int?) -> UIView? {
        if let numberOfPages = numberOfPages {
            return index >= 0 && index < numberOfPages ? dataSource?.pageView(self, viewForItemInIndex: index) : nil
        } else {
            return index >= 0 ? dataSource?.pageView(self, viewForItemInIndex: index) : nil
        }
    }
    
    open func reloadData() {
        
        let numberOfPages = dataSource?.numberOfPagesInPageView?(self)
        
        current = _fetchPage(index, numberOfPages: numberOfPages)
        
        if current != nil {
            left = _fetchPage(index - 1, numberOfPages: numberOfPages)
            right = _fetchPage(index + 1, numberOfPages: numberOfPages)
        } else {
            left = nil
            right = nil
        }
        
        _layoutSubviews()
        
        if current != nil {
            _didDisplayingView(view: current!)
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        _layoutSubviews()
    }
    
    fileprivate func _layoutOnePage() {
        scrollView.addSubview(page_1)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: page_1, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: page_1, attribute: .height, relatedBy: .equal, toItem: scrollView, attribute: .height, multiplier: 1, constant: 0)])
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scroll]|", options: [], metrics: nil, views: ["scroll": scrollView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scroll]|", options: [], metrics: nil, views: ["scroll": scrollView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[page]|", options: [], metrics: nil, views: ["page": page_1]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[one]", options: [], metrics: nil, views: ["one": page_1]))
    }
    
    fileprivate func _layoutTwoPage() {
        scrollView.addSubview(page_1)
        scrollView.addSubview(page_2)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: page_1, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: page_1, attribute: .height, relatedBy: .equal, toItem: scrollView, attribute: .height, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: page_2, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: page_2, attribute: .height, relatedBy: .equal, toItem: scrollView, attribute: .height, multiplier: 1, constant: 0)])
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scroll]|", options: [], metrics: nil, views: ["scroll": scrollView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scroll]|", options: [], metrics: nil, views: ["scroll": scrollView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[page]|", options: [], metrics: nil, views: ["page": page_1]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[page]|", options: [], metrics: nil, views: ["page": page_2]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[one][two]|", options: [], metrics: nil, views: ["one": page_1, "two": page_2]))
    }
    
    fileprivate func _layoutThreePage() {
        scrollView.addSubview(page_1)
        scrollView.addSubview(page_2)
        scrollView.addSubview(page_3)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: page_1, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: page_1, attribute: .height, relatedBy: .equal, toItem: scrollView, attribute: .height, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: page_2, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: page_2, attribute: .height, relatedBy: .equal, toItem: scrollView, attribute: .height, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: page_3, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: page_3, attribute: .height, relatedBy: .equal, toItem: scrollView, attribute: .height, multiplier: 1, constant: 0)])
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scroll]|", options: [], metrics: nil, views: ["scroll": scrollView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scroll]|", options: [], metrics: nil, views: ["scroll": scrollView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[page]|", options: [], metrics: nil, views: ["page": page_1]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[page]|", options: [], metrics: nil, views: ["page": page_2]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[page]|", options: [], metrics: nil, views: ["page": page_3]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[one][two][three]|", options: [], metrics: nil, views: ["one": page_1, "two": page_2, "three": page_3]))
    }
    
    fileprivate func _layoutSubviews() {
        
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
        
        let numberOfPages = dataSource?.numberOfPagesInPageView?(self)
        left = left ?? _fetchPage(index - 1, numberOfPages: numberOfPages)
        right = right ?? _fetchPage(index + 1, numberOfPages: numberOfPages)
        
        if left == nil && right == nil {
            _layoutOnePage()
            page_1.addSubview(current!)
            current!.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[current]|", options: [], metrics: nil, views: ["current": current!]))
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[current]|", options: [], metrics: nil, views: ["current": current!]))
            scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: scrollView.frame.width, height: scrollView.frame.height), animated: false)
        } else if left == nil {
            _layoutTwoPage()
            page_1.addSubview(current!)
            page_2.addSubview(right!)
            current!.translatesAutoresizingMaskIntoConstraints = false
            right!.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[current]|", options: [], metrics: nil, views: ["current": current!]))
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[current]|", options: [], metrics: nil, views: ["current": current!]))
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[right]|", options: [], metrics: nil, views: ["right": right!]))
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[right]|", options: [], metrics: nil, views: ["right": right!]))
            scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: scrollView.frame.width, height: scrollView.frame.height), animated: false)
        } else if right == nil {
            _layoutTwoPage()
            page_1.addSubview(left!)
            page_2.addSubview(current!)
            left!.translatesAutoresizingMaskIntoConstraints = false
            current!.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[left]|", options: [], metrics: nil, views: ["left": left!]))
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[left]|", options: [], metrics: nil, views: ["left": left!]))
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[current]|", options: [], metrics: nil, views: ["current": current!]))
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[current]|", options: [], metrics: nil, views: ["current": current!]))
            scrollView.scrollRectToVisible(CGRect(x: scrollView.frame.width, y: 0, width: scrollView.frame.width, height: scrollView.frame.height), animated: false)
        } else {
            _layoutThreePage()
            page_1.addSubview(left!)
            page_2.addSubview(current!)
            page_3.addSubview(right!)
            left!.translatesAutoresizingMaskIntoConstraints = false
            current!.translatesAutoresizingMaskIntoConstraints = false
            right!.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[left]|", options: [], metrics: nil, views: ["left": left!]))
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[left]|", options: [], metrics: nil, views: ["left": left!]))
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[current]|", options: [], metrics: nil, views: ["current": current!]))
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[current]|", options: [], metrics: nil, views: ["current": current!]))
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[right]|", options: [], metrics: nil, views: ["right": right!]))
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[right]|", options: [], metrics: nil, views: ["right": right!]))
            scrollView.scrollRectToVisible(CGRect(x: scrollView.frame.width, y: 0, width: scrollView.frame.width, height: scrollView.frame.height), animated: false)
        }
    }
    
    fileprivate func _layoutPageControl() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        if pageControl.constraints.count != 0 {
            pageControl.removeConstraints(pageControl.constraints)
        }
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                NSLayoutConstraint(item: pageControl, attribute: .bottom, relatedBy: .equal, toItem: self.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: pageControlBottomSpacing),
                NSLayoutConstraint(item: pageControl, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)])
        } else {
            NSLayoutConstraint.activate([
                NSLayoutConstraint(item: pageControl, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: pageControlBottomSpacing),
                NSLayoutConstraint(item: pageControl, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)])
        }
    }
    
    fileprivate func _didDisplayingView(view: UIView) {
        
        if let numberOfPages = dataSource?.numberOfPagesInPageView?(self) {
            pageControl.numberOfPages = numberOfPages
            pageControl.currentPage = index
        } else {
            pageControl.isHidden = true
        }
        
        delegate?.pageView?(self, didDisplayingView: view)
    }
    
    @objc func pageControlValueChanged(_ sender: UIPageControl) {
        self.swapToView(pageControl.currentPage, animated: true)
    }
    
    open func swapToView(_ index: Int, animated: Bool) {
        
        if self.index == index {
            return
        }
        
        if let jumpView = dataSource?.pageView(self, viewForItemInIndex: index) {
            if animated {
                if !scrolling && !scrollView.isDecelerating {
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
                _didDisplayingView(view: current!)
            }
        }
    }
    
    open func swapToLeft(_ animated: Bool) {
        
        if left != nil {
            if animated {
                if !scrolling && !scrollView.isDecelerating {
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
                _didDisplayingView(view: current!)
            }
        }
    }
    open func swapToRight(_ animated: Bool) {
        
        if right != nil {
            if animated {
                if !scrolling && !scrollView.isDecelerating {
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
                _didDisplayingView(view: current!)
            }
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView === self.scrollView {
            endMoving()
        }
    }
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        if scrollView === self.scrollView {
            endMoving()
            jumpSwap = nil
            scrolling = false
        }
    }
    
    fileprivate func endMoving() {
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
            _didDisplayingView(view: current!)
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
            _didDisplayingView(view: current!)
        }
    }
}

#endif
