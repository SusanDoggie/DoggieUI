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
        
        self.performSegue(withIdentifier: SDSwappageController.rootViewControllerIdentifier, sender: self)
        self.view.addSubview(self.rootView)
        
        self.rootView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[content]|", options: [], metrics: nil, views: ["content": self.rootView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[content]|", options: [], metrics: nil, views: ["content": self.rootView]))
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
        
        self.view.addSubview(toViewController.view)
        toViewController.view.frame = self.view.frame
        toViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[content]|", options: [], metrics: nil, views: ["content": toViewController.view]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[content]|", options: [], metrics: nil, views: ["content": toViewController.view]))
        
        if animated {
            self.pushViewAnimateBegin(fromView: fromViewController.view, toView: toViewController.view)
            UIView.animate(
                withDuration: springDampingTransformDuration,
                delay: springDampingTransformDelay,
                usingSpringWithDamping: springDampingRatio,
                initialSpringVelocity: springDampingVelocity,
                options: transitionAnimateOptions,
                animations: {
                    self.pushViewAnimate(fromView: fromViewController.view, toView: toViewController.view)
                },
                completion: { _ in
                    fromViewController.view.removeFromSuperview()
                    self.pushViewCompletion(fromView: fromViewController.view, toView: toViewController.view)
            })
        } else {
            fromViewController.view.removeFromSuperview()
            self.pushViewCompletion(fromView: fromViewController.view, toView: toViewController.view)
        }
    }
    
    private func pop(fromViewController: UIViewController, toViewController: UIViewController, animated: Bool) {
        
        self.view.addSubview(toViewController.view)
        toViewController.view.frame = self.view.frame
        toViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[content]|", options: [], metrics: nil, views: ["content": toViewController.view]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[content]|", options: [], metrics: nil, views: ["content": toViewController.view]))
        
        if animated {
            self.popViewAnimateBegin(fromView: fromViewController.view, toView: toViewController.view)
            UIView.animate(
                withDuration: springDampingTransformDuration,
                delay: springDampingTransformDelay,
                usingSpringWithDamping: springDampingRatio,
                initialSpringVelocity: springDampingVelocity,
                options: transitionAnimateOptions,
                animations: {
                    self.popViewAnimate(fromView: fromViewController.view, toView: toViewController.view)
                },
                completion: { _ in
                    fromViewController.view.removeFromSuperview()
                    self.popViewCompletion(fromView: fromViewController.view, toView: toViewController.view)
            })
        } else {
            fromViewController.view.removeFromSuperview()
            self.popViewCompletion(fromView: fromViewController.view, toView: toViewController.view)
        }
    }
    
    public func pushViewController(viewController: UIViewController, animated: Bool) {
        
        let currentViewController = self.childViewControllers.last
        self.addChildViewController(viewController)
        if currentViewController != nil {
            self.push(fromViewController: currentViewController!, toViewController: viewController, animated: animated)
        }
        viewController.didMove(toParentViewController: self)
    }
    
    @discardableResult
    public func popViewControllerAnimated(animated: Bool) -> UIViewController? {
        
        if self.childViewControllers.count > 1, let viewControllerToPop = self.childViewControllers.last {
            viewControllerToPop.willMove(toParentViewController: nil)
            self.pop(fromViewController: viewControllerToPop, toViewController: self.childViewControllers[self.childViewControllers.endIndex - 2], animated: animated)
            viewControllerToPop.removeFromParentViewController()
            return viewControllerToPop
        }
        return nil
    }
    
    @discardableResult
    public func popToViewController(viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        
        if let idx = self.childViewControllers.index(of: viewController), idx + 1 != self.childViewControllers.endIndex {
            let viewControllersToPop = Array(self.childViewControllers.dropFirst(idx + 1))
            for item in viewControllersToPop {
                item.willMove(toParentViewController: nil)
            }
            self.pop(fromViewController: self.childViewControllers.last!, toViewController: viewController, animated: animated)
            for item in viewControllersToPop {
                item.removeFromParentViewController()
            }
            return viewControllersToPop
        }
        return nil
    }
    
    @discardableResult
    public func popToRootViewControllerAnimated(animated: Bool) -> [UIViewController]? {
        
        if self.childViewControllers.endIndex != 1 {
            let viewControllersToPop = Array(self.childViewControllers.dropFirst(1))
            for item in viewControllersToPop {
                item.willMove(toParentViewController: nil)
            }
            self.pop(fromViewController: self.childViewControllers.last!, toViewController: self.childViewControllers.first!, animated: animated)
            for item in viewControllersToPop {
                item.removeFromParentViewController()
            }
            return viewControllersToPop
        }
        return nil
    }
    
}

extension SDSwappageController {
    
    public override func canPerformUnwindSegueAction(_ action: Selector, from fromViewController: UIViewController, withSender sender: Any) -> Bool {
        
        return self.childViewControllers.dropFirst().contains(fromViewController)
    }
    
    @available(iOS 9.0, *)
    public override func allowedChildViewControllersForUnwinding(from source: UIStoryboardUnwindSegueSource) -> [UIViewController] {
        
        if self.childViewControllers.count > 1 {
            return self.childViewControllers.dropLast().reversed()
        }
        return []
    }
    @IBAction public override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        
        if self.childViewControllers.contains(subsequentVC) {
            self.popToViewController(viewController: subsequentVC, animated: true)
        }
    }
}

extension UIViewController {
    
    public var swappage: SDSwappageController? {
        
        return self as? SDSwappageController ?? self.parent?.swappage
    }
}

public class SDSwappageSegue: UIStoryboardSegue {
    
    public override func perform() {
        
        source.swappage?.pushViewController(viewController: destination, animated: true)
    }
}
