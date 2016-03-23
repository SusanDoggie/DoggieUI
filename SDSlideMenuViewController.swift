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

public class SDSlideMenuViewController: UIViewController {
    
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
    @IBInspectable public var shadowColor: UIColor = UIColor.blackColor()
    
    @IBInspectable public var scrollsToTop: Bool = true
    
    public var MenuRootViewController: UIViewController!
    public var ContentViewController: UIViewController!
    
    private var shadowLayer: UIView!
    
    public var menuRootView: UIView! {
        return MenuRootViewController?.view
    }
    public var contentView: UIView! {
        return ContentViewController?.view
    }
    
    private var toggleState: UInt = 0 {
        didSet {
            if let scrollView = MenuRootViewController.view as? UIScrollView {
                scrollView.scrollsToTop = scrollsToTop && toggleState != 0
            }
            if let scrollView = ContentViewController.view as? UIScrollView {
                scrollView.scrollsToTop = scrollsToTop && toggleState == 0
            }
        }
    }
    
    private var panRecongnizer: UIPanGestureRecognizer!
    private var tapRecongnizer: UITapGestureRecognizer!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        shadowLayer = UIView(frame: view.frame)
        shadowLayer.backgroundColor = shadowColor
        shadowLayer.alpha = CGFloat(shadowLayerOpacity)
        shadowLayer.userInteractionEnabled = false
        view.addSubview(shadowLayer)
        
        shadowLayer.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints: [NSLayoutConstraint] = []
        constraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:|[shadow]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["shadow": shadowLayer]))
        constraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("H:|[shadow]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["shadow": shadowLayer]))
        self.view.addConstraints(constraints)
        
        performSegueWithIdentifier("MenuRoot", sender: nil)
        performSegueWithIdentifier("MainContent", sender: nil)
        
        MenuRootViewController.view.hidden = true
        shadowLayer.hidden = true
        if let scrollView = MenuRootViewController.view as? UIScrollView {
            scrollView.scrollsToTop = false
        }
        if let scrollView = ContentViewController.view as? UIScrollView {
            scrollView.scrollsToTop = true
        }
        
        panRecongnizer = UIPanGestureRecognizer(target: self, action: #selector(SDSlideMenuViewController.handlePan(_:)))
        tapRecongnizer = UITapGestureRecognizer(target: self, action: #selector(SDSlideMenuViewController.handleTap(_:)))
        panRecongnizer.delegate = self
        tapRecongnizer.delegate = self
        view.addGestureRecognizer(panRecongnizer)
        view.addGestureRecognizer(tapRecongnizer)
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SDSlideMenuViewController {
    
    private func addMenuRootViewController(rootViewController: UIViewController) {
        
        var hidden = true
        if let MenuRootViewController = MenuRootViewController {
            hidden = MenuRootViewController.view.hidden
            MenuRootViewController.willMoveToParentViewController(nil)
            MenuRootViewController.removeFromParentViewController()
            MenuRootViewController.view.removeFromSuperview()
        }
        
        shadowLayer.alpha = hidden ? CGFloat(shadowLayerOpacity) : 0
        view.sendSubviewToBack(shadowLayer)
        
        MenuRootViewController = rootViewController
        addChildViewController(MenuRootViewController)
        MenuRootViewController.didMoveToParentViewController(self)
        
        view.addSubview(MenuRootViewController.view)
        view.sendSubviewToBack(MenuRootViewController.view)
        
        MenuRootViewController.view.hidden = hidden
        shadowLayer.hidden = hidden
    }
    
    private func _addContentViewController(contentViewController: UIViewController) {
        let position = ContentViewController?.view.transform.tx ?? 0
        
        if let ContentViewController = ContentViewController {
            ContentViewController.willMoveToParentViewController(nil)
            ContentViewController.removeFromParentViewController()
            ContentViewController.view.removeFromSuperview()
        }
        
        ContentViewController = contentViewController
        addChildViewController(ContentViewController)
        ContentViewController.didMoveToParentViewController(self)
        
        view.addSubview(ContentViewController.view)
        view.bringSubviewToFront(ContentViewController.view)
        
        ContentViewController.view.transform.tx = position
        
        if self.shadowWidth > 0 {
            
            ContentViewController.view.layer.masksToBounds = false
            ContentViewController.view.layer.shadowOpacity = self.shadowOpacity
            ContentViewController.view.layer.shadowRadius = self.shadowRadius
            ContentViewController.view.layer.shadowOffset = CGSize(width: -self.shadowWidth, height: 0)
            ContentViewController.view.layer.shadowColor = self.shadowColor.CGColor
        }
    }
    
    private func addContentViewController(contentViewController: UIViewController) {
        let rightPosition = view.frame.width + self.shadowWidth
        
        if toggleState == 1 && ContentViewController != nil {
            if ContentViewController.equalTo(contentViewController) {
                self.slideDampingAnimation(0)
                self.toggleState = 0
            } else {
                UIView.animateWithDuration(
                    self.linearTransformDuration,
                    delay: self.linearTransformDelay,
                    options: UIViewAnimationOptions.CurveLinear,
                    animations: {
                        self.ContentViewController.view.transform.tx = rightPosition
                    },
                    completion: { finished in
                        self._addContentViewController(contentViewController)
                        self.slideDampingAnimation(0)
                        self.toggleState = 0
                })
            }
        } else {
            _addContentViewController(contentViewController)
        }
    }
}

extension UIViewController {
    
    @IBAction public func menuToggle(sender: AnyObject?) {
        
        self.slideMenuViewController?._menuToggle(sender)
    }
}

extension SDSlideMenuViewController {
    
    private func _menuToggle(sender: AnyObject?) {
        
        switch toggleState {
        case 0:
            slideDampingAnimation(self.transformTrailing)
            toggleState = 1
            
        case 1:
            slideDampingAnimation(0)
            toggleState = 0
            
        default:
            slideDampingAnimation(0)
            toggleState = 0
        }
    }
    
    private func slideDampingAnimation(position: CGFloat) {
        
        if position != 0 {
            MenuRootViewController.view.hidden = false
            shadowLayer.hidden = false
        }
        UIView.animateWithDuration(
            self.springDampingTransformDuration,
            delay: self.springDampingTransformDelay,
            usingSpringWithDamping: self.springDampingRatio,
            initialSpringVelocity: self.springDampingVelocity,
            options: UIViewAnimationOptions.CurveLinear,
            animations: {
                self.MenuRootViewController.view.transform.tx = 0
                self.shadowLayer.transform.tx = 0
                self.shadowLayer.alpha = position == 0 ? CGFloat(self.shadowLayerOpacity) : 0
                self.ContentViewController.view.transform.tx = position
            },
            completion: { finished in
                if position == 0 {
                    self.MenuRootViewController.view.hidden = true
                    self.shadowLayer.hidden = true
                }
        })
    }
}

extension SDSlideMenuViewController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        
        if panRecongnizer === gestureRecognizer {
            return true
        }
        
        if tapRecongnizer === gestureRecognizer {
            if toggleState != 1 {
                return false
            }
            return CGRectContainsPoint(ContentViewController.view.frame, touch.locationInView(view))
        }
        
        return true
    }
    
    public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if panRecongnizer === gestureRecognizer {
            let velocity = panRecongnizer.velocityInView(view)
            return abs(velocity.x) > abs(velocity.y) && (toggleState != 0 || velocity.x > 0)
        }
        return true
    }
    
    func handlePan(sender: UIPanGestureRecognizer) {
        
        self.view.endEditing(true)
        
        let translation = sender.translationInView(view)
        let velocity = sender.velocityInView(view)
        
        switch sender.state {
        case UIGestureRecognizerState.Began:
            
            MenuRootViewController.view.hidden = false
            shadowLayer.hidden = false
            sender.setTranslation(CGPointMake(ContentViewController.view.transform.tx, 0), inView: view)
        case UIGestureRecognizerState.Changed:
            
            var position = translation.x
            
            if position < 0 {
                position = -sqrt(-position * 16)
                MenuRootViewController.view.transform.tx = position
                shadowLayer.transform.tx = position
                shadowLayer.alpha = CGFloat(self.shadowLayerOpacity)
                ContentViewController.view.transform.tx = position
            } else if position > self.transformTrailing {
                position = sqrt((position - self.transformTrailing) * 16) + self.transformTrailing
                MenuRootViewController.view.transform.tx = 0
                shadowLayer.transform.tx = 0
                shadowLayer.alpha = 0
                ContentViewController.view.transform.tx = position
            } else {
                MenuRootViewController.view.transform.tx = 0
                shadowLayer.transform.tx = 0
                shadowLayer.alpha = max(0, min(1, CGFloat(self.shadowLayerOpacity) * (self.transformTrailing - position) / self.transformTrailing))
                ContentViewController.view.transform.tx = position
            }
            
        case UIGestureRecognizerState.Ended:
            
            if velocity.x > 0 {
                slideDampingAnimation(self.transformTrailing)
                toggleState = 1
            } else if velocity.x < 0 {
                slideDampingAnimation(0)
                toggleState = 0
            } else {
                if translation.x > self.transformTrailing / 2
                {
                    slideDampingAnimation(self.transformTrailing)
                    toggleState = 1
                } else
                {
                    slideDampingAnimation(0)
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
            slideDampingAnimation(0)
            toggleState = 0
        }
    }
}

extension UIViewController {
    
    public var slideMenuViewController: SDSlideMenuViewController? {
        
        return self as? SDSlideMenuViewController ?? self.parentViewController?.slideMenuViewController
    }
    
    private func equalTo(otherViewController: UIViewController) -> Bool {
        var selfTag = self.view.tag
        var otherTag = otherViewController.view.tag
        
        if self is UINavigationController && otherViewController is UINavigationController {
            selfTag = (self as! UINavigationController).viewControllers.first!.view.tag
            otherTag = (otherViewController as! UINavigationController).viewControllers.first!.view.tag
        }
        
        return selfTag != 0 && selfTag == otherTag
    }
}

public class SDMenuRootViewControllerSegue: UIStoryboardSegue {
    
    public override func perform() {
        
        sourceViewController.slideMenuViewController?.addMenuRootViewController(destinationViewController)
    }
}

public class SDContentViewControllerSegue: UIStoryboardSegue {
    
    public override func perform() {
        
        sourceViewController.slideMenuViewController?.addContentViewController(destinationViewController)
    }
}
