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

public class SDSwappageController: UIViewController {
    
    @IBInspectable public var springDampingTransformDuration: Double = 0.4
    @IBInspectable public var springDampingTransformDelay: Double = 0.0
    @IBInspectable public var springDampingRatio: CGFloat = 1.0
    @IBInspectable public var springDampingVelocity: CGFloat = 1.0
    
    public var transitionAnimateOptions: UIViewAnimationOptions = []
    
    private static var rootViewControllerIdentifier = "rootViewController"
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.performSegueWithIdentifier(SDSwappageController.rootViewControllerIdentifier, sender: self)
        self.view.addSubview(self.rootView)
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SDSwappageController {
    
    public func pushViewAnimateBegin(fromView: UIView, toView: UIView) {
        
        fromView.alpha = 1
        toView.alpha = 0
    }
    
    public func pushViewAnimate(fromView: UIView, toView: UIView) {
        
        fromView.alpha = 0
        toView.alpha = 1
    }
    
    public func pushViewCompletion(fromView: UIView, toView: UIView) {
        
    }
    
    public func popViewAnimateBegin(fromView: UIView, toView: UIView) {
        
        fromView.alpha = 1
        toView.alpha = 0
    }
    
    public func popViewAnimate(fromView: UIView, toView: UIView) {
        
        fromView.alpha = 0
        toView.alpha = 1
    }
    
    public func popViewCompletion(fromView: UIView, toView: UIView) {
        
    }
}

extension SDSwappageController {
    
    public var rootViewController : UIViewController! {
        return self.childViewControllers.first
    }
    
    public var rootView : UIView! {
        return rootViewController?.view
    }
    
    private func push(fromViewController: UIViewController, toViewController: UIViewController, animated: Bool) {
        
        if animated {
            self.pushViewAnimateBegin(fromViewController.view, toView: toViewController.view)
            self.view.addSubview(toViewController.view)
            UIView.animateWithDuration(
                springDampingTransformDuration,
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
            self.view.addSubview(toViewController.view)
            fromViewController.view.removeFromSuperview()
            self.pushViewCompletion(fromViewController.view, toView: toViewController.view)
        }
    }
    
    private func pop(fromViewController: UIViewController, toViewController: UIViewController, animated: Bool) {
        
        if animated {
            self.popViewAnimateBegin(fromViewController.view, toView: toViewController.view)
            self.view.addSubview(toViewController.view)
            UIView.animateWithDuration(
                springDampingTransformDuration,
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
            self.view.addSubview(toViewController.view)
            fromViewController.view.removeFromSuperview()
            self.popViewCompletion(fromViewController.view, toView: toViewController.view)
        }
    }
    
    public func pushViewController(viewController: UIViewController, animated: Bool) {
        
        let currentViewController = self.childViewControllers.last
        self.addChildViewController(viewController)
        if currentViewController != nil {
            self.push(currentViewController!, toViewController: viewController, animated: animated)
        }
        viewController.didMoveToParentViewController(self)
    }
    
    public func popViewControllerAnimated(animated: Bool) -> UIViewController? {
        
        if self.childViewControllers.count > 1, let viewControllerToPop = self.childViewControllers.last {
            viewControllerToPop.willMoveToParentViewController(nil)
            self.pop(viewControllerToPop, toViewController: self.childViewControllers[self.childViewControllers.endIndex - 2], animated: animated)
            viewControllerToPop.removeFromParentViewController()
            return viewControllerToPop
        }
        return nil
    }
    
    public func popToViewController(viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        
        if let idx = self.childViewControllers.indexOf(viewController) where idx + 1 != self.childViewControllers.endIndex {
            let viewControllersToPop = Array(self.childViewControllers.dropFirst(idx + 1))
            for item in viewControllersToPop {
                item.willMoveToParentViewController(nil)
            }
            self.pop(self.childViewControllers.last!, toViewController: viewController, animated: animated)
            for item in viewControllersToPop {
                item.removeFromParentViewController()
            }
            return viewControllersToPop
        }
        return nil
    }
    
    public func popToRootViewControllerAnimated(animated: Bool) -> [UIViewController]? {
        
        if self.childViewControllers.endIndex != 1 {
            let viewControllersToPop = Array(self.childViewControllers.dropFirst(1))
            for item in viewControllersToPop {
                item.willMoveToParentViewController(nil)
            }
            self.pop(self.childViewControllers.last!, toViewController: self.childViewControllers.first!, animated: animated)
            for item in viewControllersToPop {
                item .removeFromParentViewController()
            }
            return viewControllersToPop
        }
        return nil
    }
    
}

extension SDSwappageController {
    
    public override func canPerformUnwindSegueAction(action: Selector, fromViewController: UIViewController, withSender sender: AnyObject) -> Bool {
        
        return self.rootViewController != fromViewController
    }
    
    @available(iOS 9.0, *)
    public override func allowedChildViewControllersForUnwindingFromSource(source: UIStoryboardUnwindSegueSource) -> [UIViewController] {
        
        if self.childViewControllers.count > 1 {
            return self.childViewControllers.dropLast().reverse()
        }
        return []
    }
    @IBAction public override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        
        self.popToViewController(subsequentVC, animated: true)
    }
}

extension UIViewController {
    
    public var swappageController: SDSwappageController? {
        
        return self as? SDSwappageController ?? self.parentViewController?.swappageController
    }
}

public class SDSwappageSegue: UIStoryboardSegue {
    
    public override func perform() {
        
        sourceViewController.swappageController?.pushViewController(destinationViewController, animated: true)
    }
}
