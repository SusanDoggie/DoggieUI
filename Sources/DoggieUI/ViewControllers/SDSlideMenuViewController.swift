//
//  SDSlideMenuViewController.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2021 Susan Cheng. All rights reserved.
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
import QuartzCore

open class SDSlideMenuViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBInspectable open var transformTrailing: CGFloat = 260
    
    @IBInspectable open var linearTransformDuration: Double = 0.1
    @IBInspectable open var linearTransformDelay: Double = 0.0
    
    @IBInspectable open var springDampingTransformDuration: Double = 0.4
    @IBInspectable open var springDampingTransformDelay: Double = 0.0
    @IBInspectable open var springDampingRatio: CGFloat = 1.0
    @IBInspectable open var springDampingVelocity: CGFloat = 1.0
    
    @IBInspectable open var shadowWidth: CGFloat = 3
    @IBInspectable open var shadowRadius: CGFloat = 3
    @IBInspectable open var shadowOpacity: Float = 0.25
    @IBInspectable open var shadowLayerOpacity: Float = 0.4
    @IBInspectable open var shadowColor: UIColor = UIColor.black
    
    @IBInspectable open var scrollsToTop: Bool = true
    
    @IBInspectable open var disableMenu: Bool = false {
        didSet {
            if disableMenu && toggleState == 1 {
                slideDampingAnimation(position: 0)
                toggleState = 0
            }
        }
    }
    
    open var menuRoot: UIViewController!
    open var content: UIViewController!
    
    private var contentContainerView: UIView!
    private var contentMaskView: UIView!
    private var shadowLayer: UIView!
    
    public var menuRootView: UIView! {
        return menuRoot?.view
    }
    public var contentView: UIView! {
        return content?.view
    }
    
    private var toggleState: UInt = 0 {
        didSet {
            if let scrollView = menuRoot.view as? UIScrollView {
                scrollView.scrollsToTop = scrollsToTop && toggleState != 0
            }
            if let scrollView = content.view as? UIScrollView {
                scrollView.scrollsToTop = scrollsToTop && toggleState == 0
            }
        }
    }
    
    private var panRecongnizer: UIPanGestureRecognizer!
    private var tapRecongnizer: UITapGestureRecognizer!
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        contentContainerView = UIView(frame: view.frame)
        if self.shadowWidth > 0 {
            contentContainerView.layer.masksToBounds = false
            contentContainerView.shadowOpacity = self.shadowOpacity
            contentContainerView.shadowRadius = self.shadowRadius
            contentContainerView.shadowOffset = CGSize(width: -self.shadowWidth, height: 0)
            contentContainerView.shadowColor = self.shadowColor
        }
        view.addSubview(contentContainerView)
        
        shadowLayer = UIView(frame: view.frame)
        shadowLayer.backgroundColor = shadowColor
        shadowLayer.alpha = CGFloat(shadowLayerOpacity)
        shadowLayer.isUserInteractionEnabled = false
        view.addSubview(shadowLayer)
        
        contentMaskView = UIView(frame: view.frame)
        contentMaskView.layer.masksToBounds = true
        contentContainerView.addSubview(contentMaskView)
        
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        shadowLayer.translatesAutoresizingMaskIntoConstraints = false
        contentMaskView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[content]|", options: [], metrics: nil, views: ["content": contentContainerView!]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[content]|", options: [], metrics: nil, views: ["content": contentContainerView!]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[shadow]|", options: [], metrics: nil, views: ["shadow": shadowLayer!]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[shadow]|", options: [], metrics: nil, views: ["shadow": shadowLayer!]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[mask]|", options: [], metrics: nil, views: ["mask": contentMaskView!]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[mask]|", options: [], metrics: nil, views: ["mask": contentMaskView!]))
        
        performSegue(withIdentifier: "MenuRoot", sender: nil)
        performSegue(withIdentifier: "MainContent", sender: nil)
        
        menuRoot.view.isHidden = true
        shadowLayer.isHidden = true
        if let scrollView = menuRoot.view as? UIScrollView {
            scrollView.scrollsToTop = false
        }
        if let scrollView = content.view as? UIScrollView {
            scrollView.scrollsToTop = true
        }
        
        panRecongnizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        tapRecongnizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        panRecongnizer.delegate = self
        tapRecongnizer.delegate = self
        view.addGestureRecognizer(panRecongnizer)
        view.addGestureRecognizer(tapRecongnizer)
    }
    
    open override var prefersStatusBarHidden: Bool {
        return content?.prefersStatusBarHidden ?? super.prefersStatusBarHidden
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return content?.preferredStatusBarStyle ?? super.preferredStatusBarStyle
    }
    
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return content?.preferredStatusBarUpdateAnimation ?? super.preferredStatusBarUpdateAnimation
    }
    
    open override var childForStatusBarHidden: UIViewController? {
        return content?.childForStatusBarHidden
    }
    
    open override var childForStatusBarStyle: UIViewController? {
        return content?.childForStatusBarStyle
    }
    
    fileprivate func addmenuRoot(rootViewController: UIViewController) {
        
        var hidden = true
        if let menuRoot = menuRoot {
            hidden = menuRoot.view.isHidden
            menuRoot.willMove(toParent: nil)
            menuRoot.removeFromParent()
            menuRoot.view.removeFromSuperview()
        }
        
        shadowLayer.alpha = hidden ? CGFloat(shadowLayerOpacity) : 0
        view.sendSubviewToBack(shadowLayer)
        
        menuRoot = rootViewController
        addChild(menuRoot)
        menuRoot.didMove(toParent: self)
        
        view.addSubview(menuRoot.view)
        view.sendSubviewToBack(menuRoot.view)
        
        menuRoot.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[menu]|", options: [], metrics: nil, views: ["menu": menuRoot.view!]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[menu]|", options: [], metrics: nil, views: ["menu": menuRoot.view!]))
        
        menuRoot.view.isHidden = hidden
        shadowLayer.isHidden = hidden
    }
    
    private func _addContentViewController(contentViewController: UIViewController) {
        
        if let ContentViewController = content {
            ContentViewController.willMove(toParent: nil)
            ContentViewController.removeFromParent()
            ContentViewController.view.removeFromSuperview()
        }
        
        content = contentViewController
        addChild(content)
        content.didMove(toParent: self)
        
        contentMaskView.addSubview(content.view)
        view.bringSubviewToFront(contentContainerView)
        
        content.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[content]|", options: [], metrics: nil, views: ["content": content.view!]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[content]|", options: [], metrics: nil, views: ["content": content.view!]))
        
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    fileprivate func addContentViewController(contentViewController: UIViewController) {
        
        if content == nil {
            _addContentViewController(contentViewController: contentViewController)
        } else {
            let rightPosition = view.frame.width + self.shadowWidth
            
            if toggleState == 1 {
                if content.equalTo(otherViewController: contentViewController) {
                    self.slideDampingAnimation(position: 0)
                    self.toggleState = 0
                } else {
                    UIView.animate(
                        withDuration: self.linearTransformDuration,
                        delay: self.linearTransformDelay,
                        options: .curveLinear,
                        animations: {
                            self.contentContainerView.transform.tx = rightPosition
                        },
                        completion: { finished in
                            self._addContentViewController(contentViewController: contentViewController)
                            self.slideDampingAnimation(position: 0)
                            self.toggleState = 0
                    })
                }
            } else if !content.equalTo(otherViewController: contentViewController) {
                
                let _shadowLayer = UIView(frame: view.frame)
                _shadowLayer.backgroundColor = self.shadowColor
                _shadowLayer.alpha = 0
                _shadowLayer.isUserInteractionEnabled = false
                view.addSubview(_shadowLayer)
                view.bringSubviewToFront(_shadowLayer)
                
                view.addSubview(contentViewController.view)
                view.bringSubviewToFront(contentViewController.view)
                contentViewController.view.transform.tx = rightPosition
                
                let translatesAutoresizingMaskIntoConstraints = contentViewController.view.translatesAutoresizingMaskIntoConstraints
                
                _shadowLayer.translatesAutoresizingMaskIntoConstraints = false
                contentViewController.view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[shadow]|", options: [], metrics: nil, views: ["shadow": shadowLayer!]))
                NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[shadow]|", options: [], metrics: nil, views: ["shadow": shadowLayer!]))
                NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[content]|", options: [], metrics: nil, views: ["content": contentViewController.view!]))
                NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[content]|", options: [], metrics: nil, views: ["content": contentViewController.view!]))
                
                let masksToBounds = contentViewController.view.layer.masksToBounds
                let shadowOpacity = contentViewController.view.shadowOpacity
                let shadowRadius = contentViewController.view.shadowRadius
                let shadowOffset = contentViewController.view.shadowOffset
                let shadowColor = contentViewController.view.shadowColor
                if self.shadowWidth > 0 {
                    contentViewController.view.layer.masksToBounds = false
                    contentViewController.view.shadowOpacity = self.shadowOpacity
                    contentViewController.view.shadowRadius = self.shadowRadius
                    contentViewController.view.shadowOffset = CGSize(width: -self.shadowWidth, height: 0)
                    contentViewController.view.shadowColor = self.shadowColor
                }
                
                UIView.animate(
                    withDuration: self.springDampingTransformDuration,
                    delay: self.springDampingTransformDelay,
                    usingSpringWithDamping: self.springDampingRatio,
                    initialSpringVelocity: self.springDampingVelocity,
                    options: .curveLinear,
                    animations: {
                        _shadowLayer.alpha = CGFloat(self.shadowLayerOpacity)
                        contentViewController.view.transform.tx = 0
                    },
                    completion: { finished in
                        _shadowLayer.removeFromSuperview()
                        contentViewController.view.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints
                        if self.shadowWidth > 0 {
                            contentViewController.view.layer.masksToBounds = masksToBounds
                            contentViewController.view.shadowOpacity = shadowOpacity
                            contentViewController.view.shadowRadius = shadowRadius
                            contentViewController.view.shadowOffset = shadowOffset
                            contentViewController.view.shadowColor = shadowColor
                        }
                        contentViewController.view.removeFromSuperview()
                        self._addContentViewController(contentViewController: contentViewController)
                })
            }
        }
    }
    
    fileprivate func _menuToggle(_ sender: Any) {
        
        switch toggleState {
        case 0:
            slideDampingAnimation(position: self.transformTrailing)
            toggleState = 1
            
        case 1:
            slideDampingAnimation(position: 0)
            toggleState = 0
            
        default:
            slideDampingAnimation(position: 0)
            toggleState = 0
        }
    }
    
    private func slideDampingAnimation(position: CGFloat) {
        
        if position != 0 {
            menuRoot.view.isHidden = false
            shadowLayer.isHidden = false
            contentMaskView.isUserInteractionEnabled = false
        }
        UIView.animate(
            withDuration: self.springDampingTransformDuration,
            delay: self.springDampingTransformDelay,
            usingSpringWithDamping: self.springDampingRatio,
            initialSpringVelocity: self.springDampingVelocity,
            options: .curveLinear,
            animations: {
                self.menuRoot.view.transform.tx = 0
                self.shadowLayer.transform.tx = 0
                self.shadowLayer.alpha = position == 0 ? CGFloat(self.shadowLayerOpacity) : 0
                self.contentContainerView.transform.tx = position
            },
            completion: { finished in
                if position == 0 {
                    self.menuRoot.view.isHidden = true
                    self.shadowLayer.isHidden = true
                    self.contentMaskView.isUserInteractionEnabled = true
                }
        })
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if panRecongnizer === gestureRecognizer {
            return !disableMenu
        }
        
        if tapRecongnizer === gestureRecognizer {
            if toggleState != 1 {
                return false
            }
            return contentContainerView.frame.contains(touch.location(in: view)) && !disableMenu
        }
        
        return !disableMenu
    }
    
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if panRecongnizer === gestureRecognizer {
            let velocity = panRecongnizer.velocity(in: view)
            return abs(velocity.x) > abs(velocity.y) && (toggleState != 0 || velocity.x > 0)
        }
        return true
    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        
        self.view.endEditing(true)
        
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        
        switch sender.state {
        case UIGestureRecognizer.State.began:
            
            menuRoot.view.isHidden = false
            shadowLayer.isHidden = false
            contentMaskView.isUserInteractionEnabled = false
            sender.setTranslation(CGPoint(x: contentContainerView.transform.tx, y: 0), in: view)
        case UIGestureRecognizer.State.changed:
            
            var position = translation.x
            
            if position < 0 {
                position = -sqrt(-position * 16)
                menuRoot.view.transform.tx = position
                shadowLayer.transform.tx = position
                shadowLayer.alpha = CGFloat(self.shadowLayerOpacity)
                contentContainerView.transform.tx = position
            } else if position > self.transformTrailing {
                position = sqrt((position - self.transformTrailing) * 16) + self.transformTrailing
                menuRoot.view.transform.tx = 0
                shadowLayer.transform.tx = 0
                shadowLayer.alpha = 0
                contentContainerView.transform.tx = position
            } else {
                menuRoot.view.transform.tx = 0
                shadowLayer.transform.tx = 0
                shadowLayer.alpha = max(0, min(1, CGFloat(self.shadowLayerOpacity) * (self.transformTrailing - position) / self.transformTrailing))
                contentContainerView.transform.tx = position
            }
            
        case UIGestureRecognizer.State.ended:
            
            if velocity.x > 0 {
                slideDampingAnimation(position: self.transformTrailing)
                toggleState = 1
            } else if velocity.x < 0 {
                slideDampingAnimation(position: 0)
                toggleState = 0
            } else {
                if translation.x > self.transformTrailing / 2
                {
                    slideDampingAnimation(position: self.transformTrailing)
                    toggleState = 1
                } else
                {
                    slideDampingAnimation(position: 0)
                    toggleState = 0
                }
            }
            
        default:
            break
        }
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        
        self.view.endEditing(true)
        
        if toggleState == 1 {
            slideDampingAnimation(position: 0)
            toggleState = 0
        }
    }
}

extension UIViewController {
    
    @IBAction open func menuToggle(_ sender: Any) {
        
        self.slideMenu?._menuToggle(sender)
    }
    
    open var slideMenu: SDSlideMenuViewController? {
        
        return self as? SDSlideMenuViewController ?? self.parent?.slideMenu
    }
    
    fileprivate func equalTo(otherViewController: UIViewController) -> Bool {
        var selfTag = self.view.tag
        var otherTag = otherViewController.view.tag
        
        if self is UINavigationController && otherViewController is UINavigationController {
            selfTag = (self as! UINavigationController).viewControllers.first!.view.tag
            otherTag = (otherViewController as! UINavigationController).viewControllers.first!.view.tag
        }
        
        return selfTag != 0 && selfTag == otherTag
    }
}

open class SDMenuRootViewControllerSegue: UIStoryboardSegue {
    
    open override func perform() {
        
        source.slideMenu?.addmenuRoot(rootViewController: destination)
    }
}

open class SDContentViewControllerSegue: UIStoryboardSegue {
    
    open override func perform() {
        
        source.slideMenu?.addContentViewController(contentViewController: destination)
    }
}

#endif
