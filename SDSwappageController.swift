//
//  SDSwappageController.swift
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

open class SDSwappageController: UIViewController {
    
    @IBInspectable open var springDampingTransformDuration: Double = 0.4
    @IBInspectable open var springDampingTransformDelay: Double = 0.0
    @IBInspectable open var springDampingRatio: CGFloat = 1.0
    @IBInspectable open var springDampingVelocity: CGFloat = 1.0
    
    open var transitionAnimateOptions: UIViewAnimationOptions = []
    
    fileprivate static var rootViewControllerIdentifier = "rootViewController"
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.performSegue(withIdentifier: SDSwappageController.rootViewControllerIdentifier, sender: self)
        self.view.addSubview(self.rootView)
        
        self.rootView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[content]|", options: [], metrics: nil, views: ["content": self.rootView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[content]|", options: [], metrics: nil, views: ["content": self.rootView]))
    }
    
    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SDSwappageController {
    
    public func pushViewAnimateBegin(_ fromView: UIView, toView: UIView) {
        
        fromView.alpha = 1
        toView.alpha = 0
    }
    
    public func pushViewAnimate(_ fromView: UIView, toView: UIView) {
        
        fromView.alpha = 0
        toView.alpha = 1
    }
    
    public func pushViewCompletion(_ fromView: UIView, toView: UIView) {
        
    }
    
    public func popViewAnimateBegin(_ fromView: UIView, toView: UIView) {
        
        fromView.alpha = 1
        toView.alpha = 0
    }
    
    public func popViewAnimate(_ fromView: UIView, toView: UIView) {
        
        fromView.alpha = 0
        toView.alpha = 1
    }
    
    public func popViewCompletion(_ fromView: UIView, toView: UIView) {
        
    }
}

extension SDSwappageController {
    
    public var rootViewController : UIViewController! {
        return self.childViewControllers.first
    }
    
    public var rootView : UIView! {
        return rootViewController?.view
    }
    
    fileprivate func push(_ fromViewController: UIViewController, toViewController: UIViewController, animated: Bool) {
        
        self.view.addSubview(toViewController.view)
        toViewController.view.frame = self.view.frame
        toViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[content]|", options: [], metrics: nil, views: ["content": toViewController.view]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[content]|", options: [], metrics: nil, views: ["content": toViewController.view]))
        
        if animated {
            self.pushViewAnimateBegin(fromViewController.view, toView: toViewController.view)
            UIView.animate(
                withDuration: springDampingTransformDuration,
                delay: springDampingTransformDelay,
                usingSpringWithDamping: springDampingRatio,
                initialSpringVelocity: springDampingVelocity,
                options: transitionAnimateOptions,
                animations: {
                    self.pushViewAnimate(fromViewController.view, toView: toViewController.view)
                },
                completion: { _ in
                    fromViewController.view.removeFromSuperview()
                    self.pushViewCompletion(fromViewController.view, toView: toViewController.view)
            })
        } else {
            fromViewController.view.removeFromSuperview()
            self.pushViewCompletion(fromViewController.view, toView: toViewController.view)
        }
    }
    
    fileprivate func pop(_ fromViewController: UIViewController, toViewController: UIViewController, animated: Bool) {
        
        self.view.addSubview(toViewController.view)
        toViewController.view.frame = self.view.frame
        toViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[content]|", options: [], metrics: nil, views: ["content": toViewController.view]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[content]|", options: [], metrics: nil, views: ["content": toViewController.view]))
        
        if animated {
            self.popViewAnimateBegin(fromViewController.view, toView: toViewController.view)
            UIView.animate(
                withDuration: springDampingTransformDuration,
                delay: springDampingTransformDelay,
                usingSpringWithDamping: springDampingRatio,
                initialSpringVelocity: springDampingVelocity,
                options: transitionAnimateOptions,
                animations: {
                    self.popViewAnimate(fromViewController.view, toView: toViewController.view)
                },
                completion: { _ in
                    fromViewController.view.removeFromSuperview()
                    self.popViewCompletion(fromViewController.view, toView: toViewController.view)
            })
        } else {
            fromViewController.view.removeFromSuperview()
            self.popViewCompletion(fromViewController.view, toView: toViewController.view)
        }
    }
    
    public func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        let currentViewController = self.childViewControllers.last
        self.addChildViewController(viewController)
        if currentViewController != nil {
            self.push(currentViewController!, toViewController: viewController, animated: animated)
        }
        viewController.didMove(toParentViewController: self)
    }
    
    @discardableResult
    public func popViewControllerAnimated(_ animated: Bool) -> UIViewController? {
        
        if self.childViewControllers.count > 1, let viewControllerToPop = self.childViewControllers.last {
            viewControllerToPop.willMove(toParentViewController: nil)
            self.pop(viewControllerToPop, toViewController: self.childViewControllers[self.childViewControllers.endIndex - 2], animated: animated)
            viewControllerToPop.removeFromParentViewController()
            return viewControllerToPop
        }
        return nil
    }
    
    @discardableResult
    public func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        
        if let idx = self.childViewControllers.index(of: viewController), idx + 1 != self.childViewControllers.endIndex {
            let viewControllersToPop = Array(self.childViewControllers.dropFirst(idx + 1))
            for item in viewControllersToPop {
                item.willMove(toParentViewController: nil)
            }
            self.pop(self.childViewControllers.last!, toViewController: viewController, animated: animated)
            for item in viewControllersToPop {
                item.removeFromParentViewController()
            }
            return viewControllersToPop
        }
        return nil
    }
    
    @discardableResult
    public func popToRootViewControllerAnimated(_ animated: Bool) -> [UIViewController]? {
        
        if self.childViewControllers.endIndex != 1 {
            let viewControllersToPop = Array(self.childViewControllers.dropFirst(1))
            for item in viewControllersToPop {
                item.willMove(toParentViewController: nil)
            }
            self.pop(self.childViewControllers.last!, toViewController: self.childViewControllers.first!, animated: animated)
            for item in viewControllersToPop {
                item.removeFromParentViewController()
            }
            return viewControllersToPop
        }
        return nil
    }
    
}

extension SDSwappageController {
    
    open override func canPerformUnwindSegueAction(_ action: Selector, from fromViewController: UIViewController, withSender sender: Any) -> Bool {
        
        return self.childViewControllers.dropFirst().contains(fromViewController)
    }
    
    @available(iOS 9.0, *)
    open override func allowedChildViewControllersForUnwinding(from source: UIStoryboardUnwindSegueSource) -> [UIViewController] {
        
        if self.childViewControllers.count > 1 {
            return self.childViewControllers.dropLast().reversed()
        }
        return []
    }
    @IBAction open override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        
        if self.childViewControllers.contains(subsequentVC) {
            self.popToViewController(subsequentVC, animated: true)
        }
    }
}

extension UIViewController {
    
    public var swappage: SDSwappageController? {
        
        return self as? SDSwappageController ?? self.parent?.swappage
    }
}

open class SDSwappageSegue: UIStoryboardSegue {
    
    open override func perform() {
        
        source.swappage?.pushViewController(destination, animated: true)
    }
}
