//
//  SDSwappageController.swift
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

extension UIViewController {
    
    @objc open func swappagePushViewAnimateBegin(from fromViewController: UIViewController, to toViewController: UIViewController) {
        self.swappage?.pushViewAnimateBegin(from: fromViewController, to: toViewController)
    }
    
    @objc open func swappagePushViewAnimate(from fromViewController: UIViewController, to toViewController: UIViewController) {
        self.swappage?.pushViewAnimate(from: fromViewController, to: toViewController)
    }
    
    @objc open func swappagePushViewCompletion(from fromViewController: UIViewController, to toViewController: UIViewController) {
        self.swappage?.pushViewCompletion(from: fromViewController, to: toViewController)
    }
    
    @objc open func swappagePopViewAnimateBegin(from fromViewController: UIViewController, to toViewController: UIViewController) {
        self.swappage?.popViewAnimateBegin(from: fromViewController, to: toViewController)
    }
    
    @objc open func swappagePopViewAnimate(from fromViewController: UIViewController, to toViewController: UIViewController) {
        self.swappage?.popViewAnimate(from: fromViewController, to: toViewController)
    }
    
    @objc open func swappagePopViewCompletion(from fromViewController: UIViewController, to toViewController: UIViewController) {
        self.swappage?.popViewCompletion(from: fromViewController, to: toViewController)
    }
}

extension SDSwappageController {
    
    @objc open func pushViewAnimateBegin(from fromViewController: UIViewController, to toViewController: UIViewController) {
        
        fromViewController.view?.alpha = 1
        toViewController.view?.alpha = 0
    }
    
    @objc open func pushViewAnimate(from fromViewController: UIViewController, to toViewController: UIViewController) {
        
        fromViewController.view?.alpha = 0
        toViewController.view?.alpha = 1
    }
    
    @objc open func pushViewCompletion(from fromViewController: UIViewController, to toViewController: UIViewController) {
        
    }
    
    @objc open func popViewAnimateBegin(from fromViewController: UIViewController, to toViewController: UIViewController) {
        
        fromViewController.view?.alpha = 1
        toViewController.view?.alpha = 0
    }
    
    @objc open func popViewAnimate(from fromViewController: UIViewController, to toViewController: UIViewController) {
        
        fromViewController.view?.alpha = 0
        toViewController.view?.alpha = 1
    }
    
    @objc open func popViewCompletion(from fromViewController: UIViewController, to toViewController: UIViewController) {
        
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
            toViewController.swappagePushViewAnimateBegin(from: fromViewController, to: toViewController)
            UIView.animate(
                withDuration: springDampingTransformDuration,
                delay: springDampingTransformDelay,
                usingSpringWithDamping: springDampingRatio,
                initialSpringVelocity: springDampingVelocity,
                options: transitionAnimateOptions,
                animations: {
                    toViewController.swappagePushViewAnimate(from: fromViewController, to: toViewController)
                },
                completion: { _ in
                    fromViewController.view.removeFromSuperview()
                    toViewController.swappagePushViewCompletion(from: fromViewController, to: toViewController)
            })
        } else {
            fromViewController.view.removeFromSuperview()
            toViewController.swappagePushViewCompletion(from: fromViewController, to: toViewController)
        }
    }
    
    fileprivate func pop(_ fromViewController: UIViewController, toViewController: UIViewController, animated: Bool) {
        
        self.view.addSubview(toViewController.view)
        toViewController.view.frame = self.view.frame
        toViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[content]|", options: [], metrics: nil, views: ["content": toViewController.view]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[content]|", options: [], metrics: nil, views: ["content": toViewController.view]))
        
        if animated {
            fromViewController.swappagePopViewAnimateBegin(from: fromViewController, to: toViewController)
            UIView.animate(
                withDuration: springDampingTransformDuration,
                delay: springDampingTransformDelay,
                usingSpringWithDamping: springDampingRatio,
                initialSpringVelocity: springDampingVelocity,
                options: transitionAnimateOptions,
                animations: {
                    fromViewController.swappagePopViewAnimate(from: fromViewController, to: toViewController)
                },
                completion: { _ in
                    fromViewController.view.removeFromSuperview()
                    fromViewController.swappagePopViewCompletion(from: fromViewController, to: toViewController)
            })
        } else {
            fromViewController.view.removeFromSuperview()
            fromViewController.swappagePopViewCompletion(from: fromViewController, to: toViewController)
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
    @IBAction open func unwindSwapage(for unwindSegue: UIStoryboardSegue) {
        self.popViewControllerAnimated(true)
    }
    @IBAction open func unwindSwapageToRoot(for unwindSegue: UIStoryboardSegue) {
        self.popToRootViewControllerAnimated(true)
    }
    open override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        
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
