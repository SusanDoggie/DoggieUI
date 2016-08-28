//
//  SDSlideMenuViewController.swift
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

public class SDSlideMenuViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBInspectable public var transformTrailing: CGFloat = 260
    
    @IBInspectable public var linearTransformDuration: Double = 0.1
    @IBInspectable public var linearTransformDelay: Double = 0.0
    
    @IBInspectable public var springDampingTransformDuration: Double = 0.4
    @IBInspectable public var springDampingTransformDelay: Double = 0.0
    @IBInspectable public var springDampingRatio: CGFloat = 1.0
    @IBInspectable public var springDampingVelocity: CGFloat = 1.0
    
    @IBInspectable public var shadowWidth: CGFloat = 3
    @IBInspectable public var shadowRadius: CGFloat = 3
    @IBInspectable public var shadowOpacity: Float = 0.25
    @IBInspectable public var shadowLayerOpacity: Float = 0.4
    @IBInspectable public var shadowColor: UIColor = UIColor.black
    
    @IBInspectable public var scrollsToTop: Bool = true
    
    @IBInspectable public var disableMenu: Bool = false {
        didSet {
            if disableMenu && toggleState == 1 {
                slideDampingAnimation(position: 0)
                toggleState = 0
            }
        }
    }
    
    public var menuRoot: UIViewController!
    public var content: UIViewController!
    
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
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[content]|", options: [], metrics: nil, views: ["content": contentContainerView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[content]|", options: [], metrics: nil, views: ["content": contentContainerView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[shadow]|", options: [], metrics: nil, views: ["shadow": shadowLayer]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[shadow]|", options: [], metrics: nil, views: ["shadow": shadowLayer]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[mask]|", options: [], metrics: nil, views: ["mask": contentMaskView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[mask]|", options: [], metrics: nil, views: ["mask": contentMaskView]))
        
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
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func addmenuRoot(rootViewController: UIViewController) {
        
        var hidden = true
        if let menuRoot = menuRoot {
            hidden = menuRoot.view.isHidden
            menuRoot.willMove(toParentViewController: nil)
            menuRoot.removeFromParentViewController()
            menuRoot.view.removeFromSuperview()
        }
        
        shadowLayer.alpha = hidden ? CGFloat(shadowLayerOpacity) : 0
        view.sendSubview(toBack: shadowLayer)
        
        menuRoot = rootViewController
        addChildViewController(menuRoot)
        menuRoot.didMove(toParentViewController: self)
        
        view.addSubview(menuRoot.view)
        view.sendSubview(toBack: menuRoot.view)
        
        menuRoot.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[menu]|", options: [], metrics: nil, views: ["menu": menuRoot.view]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[menu]|", options: [], metrics: nil, views: ["menu": menuRoot.view]))
        
        menuRoot.view.isHidden = hidden
        shadowLayer.isHidden = hidden
    }
    
    private func _addContentViewController(contentViewController: UIViewController) {
        
        if let ContentViewController = content {
            ContentViewController.willMove(toParentViewController: nil)
            ContentViewController.removeFromParentViewController()
            ContentViewController.view.removeFromSuperview()
        }
        
        content = contentViewController
        addChildViewController(content)
        content.didMove(toParentViewController: self)
        
        contentMaskView.addSubview(content.view)
        view.bringSubview(toFront: contentContainerView)
        
        content.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[content]|", options: [], metrics: nil, views: ["content": content.view]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[content]|", options: [], metrics: nil, views: ["content": content.view]))
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
                        options: UIViewAnimationOptions.curveLinear,
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
                view.bringSubview(toFront: _shadowLayer)
                
                view.addSubview(contentViewController.view)
                view.bringSubview(toFront: contentViewController.view)
                contentViewController.view.transform.tx = rightPosition
                
                let translatesAutoresizingMaskIntoConstraints = contentViewController.view.translatesAutoresizingMaskIntoConstraints
                
                _shadowLayer.translatesAutoresizingMaskIntoConstraints = false
                contentViewController.view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[shadow]|", options: [], metrics: nil, views: ["shadow": shadowLayer]))
                NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[shadow]|", options: [], metrics: nil, views: ["shadow": shadowLayer]))
                NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[content]|", options: [], metrics: nil, views: ["content": contentViewController.view]))
                NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[content]|", options: [], metrics: nil, views: ["content": contentViewController.view]))
                
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
                    options: UIViewAnimationOptions.curveLinear,
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
    
    fileprivate func _menuToggle(sender: AnyObject?) {
        
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
            options: UIViewAnimationOptions.curveLinear,
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
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
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
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if panRecongnizer === gestureRecognizer {
            let velocity = panRecongnizer.velocity(in: view)
            return abs(velocity.x) > abs(velocity.y) && (toggleState != 0 || velocity.x > 0)
        }
        return true
    }
    
    func handlePan(sender: UIPanGestureRecognizer) {
        
        self.view.endEditing(true)
        
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        
        switch sender.state {
        case UIGestureRecognizerState.began:
            
            menuRoot.view.isHidden = false
            shadowLayer.isHidden = false
            contentMaskView.isUserInteractionEnabled = false
            sender.setTranslation(CGPoint(x: contentContainerView.transform.tx, y: 0), in: view)
        case UIGestureRecognizerState.changed:
            
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
            
        case UIGestureRecognizerState.ended:
            
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
    func handleTap(sender: UITapGestureRecognizer) {
        
        self.view.endEditing(true)
        
        if toggleState == 1 {
            slideDampingAnimation(position: 0)
            toggleState = 0
        }
    }
}

extension UIViewController {
    
    @IBAction public func menuToggle(sender: AnyObject?) {
        
        self.slideMenu?._menuToggle(sender: sender)
    }
    
    public var slideMenu: SDSlideMenuViewController? {
        
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

public class SDmenuRootSegue: UIStoryboardSegue {
    
    public override func perform() {
        
        source.slideMenu?.addmenuRoot(rootViewController: destination)
    }
}

public class SDContentViewControllerSegue: UIStoryboardSegue {
    
    public override func perform() {
        
        source.slideMenu?.addContentViewController(contentViewController: destination)
    }
}
