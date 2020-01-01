//
//  SDSwappageController.swift
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
    
    open var transitionAnimateOptions: UIView.AnimationOptions = []
    
    fileprivate static var rootViewControllerIdentifier = "rootViewController"
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.performSegue(withIdentifier: SDSwappageController.rootViewControllerIdentifier, sender: self)
        self.view.addSubview(self.rootView)
        
        self.rootView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[content]|", options: [], metrics: nil, views: ["content": self.rootView!]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[content]|", options: [], metrics: nil, views: ["content": self.rootView!]))
    }
    
    open override var prefersStatusBarHidden: Bool {
        return children.last?.prefersStatusBarHidden ?? super.prefersStatusBarHidden
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return children.last?.preferredStatusBarStyle ?? super.preferredStatusBarStyle
    }
    
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return children.last?.preferredStatusBarUpdateAnimation ?? super.preferredStatusBarUpdateAnimation
    }
    
    open override var childForStatusBarHidden: UIViewController? {
        return children.last?.childForStatusBarHidden
    }
    
    open override var childForStatusBarStyle: UIViewController? {
        return children.last?.childForStatusBarStyle
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
        return self.children.first
    }
    
    public var rootView : UIView! {
        return rootViewController?.view
    }
    
    fileprivate func push(_ fromViewController: UIViewController, toViewController: UIViewController, animated: Bool) {
        
        DispatchQueue.main.async {
            self.view.doAnimation { completeAnimation in
                
                self.view.addSubview(toViewController.view)
                toViewController.view.frame = self.view.frame
                toViewController.view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[content]|", options: [], metrics: nil, views: ["content": toViewController.view!]))
                NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[content]|", options: [], metrics: nil, views: ["content": toViewController.view!]))
                
                if animated {
                    toViewController.swappagePushViewAnimateBegin(from: fromViewController, to: toViewController)
                    UIView.animate(
                        withDuration: self.springDampingTransformDuration,
                        delay: self.springDampingTransformDelay,
                        usingSpringWithDamping: self.springDampingRatio,
                        initialSpringVelocity: self.springDampingVelocity,
                        options: self.transitionAnimateOptions,
                        animations: { toViewController.swappagePushViewAnimate(from: fromViewController, to: toViewController) },
                        completion: { _ in
                            fromViewController.view.removeFromSuperview()
                            toViewController.swappagePushViewCompletion(from: fromViewController, to: toViewController)
                            completeAnimation()
                    })
                } else {
                    fromViewController.view.removeFromSuperview()
                    toViewController.swappagePushViewCompletion(from: fromViewController, to: toViewController)
                    completeAnimation()
                }
            }
        }
    }
    
    fileprivate func pop(_ fromViewController: UIViewController, toViewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
        
        DispatchQueue.main.async {
            self.view.doAnimation { completeAnimation in
                
                self.view.addSubview(toViewController.view)
                toViewController.view.frame = self.view.frame
                toViewController.view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[content]|", options: [], metrics: nil, views: ["content": toViewController.view!]))
                NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[content]|", options: [], metrics: nil, views: ["content": toViewController.view!]))
                
                if animated {
                    fromViewController.swappagePopViewAnimateBegin(from: fromViewController, to: toViewController)
                    UIView.animate(
                        withDuration: self.springDampingTransformDuration,
                        delay: self.springDampingTransformDelay,
                        usingSpringWithDamping: self.springDampingRatio,
                        initialSpringVelocity: self.springDampingVelocity,
                        options: self.transitionAnimateOptions,
                        animations: { fromViewController.swappagePopViewAnimate(from: fromViewController, to: toViewController) },
                        completion: { _ in
                            fromViewController.view.removeFromSuperview()
                            fromViewController.swappagePopViewCompletion(from: fromViewController, to: toViewController)
                            completion()
                            completeAnimation()
                    })
                } else {
                    fromViewController.view.removeFromSuperview()
                    fromViewController.swappagePopViewCompletion(from: fromViewController, to: toViewController)
                    completion()
                    completeAnimation()
                }
            }
        }
    }
    
    public func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        let currentViewController = self.children.last
        self.addChild(viewController)
        self.setNeedsStatusBarAppearanceUpdate()
        if currentViewController != nil {
            self.push(currentViewController!, toViewController: viewController, animated: animated)
        }
        viewController.didMove(toParent: self)
    }
    
    @discardableResult
    public func popViewControllerAnimated(_ animated: Bool) -> UIViewController? {
        
        if self.children.count > 1, let viewControllerToPop = self.children.last {
            viewControllerToPop.willMove(toParent: nil)
            self.pop(viewControllerToPop, toViewController: self.children[self.children.endIndex - 2], animated: animated) {
                viewControllerToPop.removeFromParent()
                self.setNeedsStatusBarAppearanceUpdate()
            }
            return viewControllerToPop
        }
        return nil
    }
    
    @discardableResult
    public func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        
        if let idx = self.children.firstIndex(of: viewController), idx + 1 != self.children.endIndex {
            let viewControllersToPop = Array(self.children.dropFirst(idx + 1))
            for item in viewControllersToPop {
                item.willMove(toParent: nil)
            }
            self.pop(self.children.last!, toViewController: viewController, animated: animated) {
                for item in viewControllersToPop {
                    item.removeFromParent()
                }
                self.setNeedsStatusBarAppearanceUpdate()
            }
            return viewControllersToPop
        }
        return nil
    }
    
    @discardableResult
    public func popToRootViewControllerAnimated(_ animated: Bool) -> [UIViewController]? {
        
        if self.children.endIndex != 1 {
            let viewControllersToPop = Array(self.children.dropFirst(1))
            for item in viewControllersToPop {
                item.willMove(toParent: nil)
            }
            self.pop(self.children.last!, toViewController: self.children.first!, animated: animated) {
                for item in viewControllersToPop {
                    item.removeFromParent()
                }
                self.setNeedsStatusBarAppearanceUpdate()
            }
            return viewControllersToPop
        }
        return nil
    }
    
}

extension SDSwappageController {
    
    open override func canPerformUnwindSegueAction(_ action: Selector, from fromViewController: UIViewController, withSender sender: Any) -> Bool {
        
        return self.children.dropFirst().contains(fromViewController)
    }
    
    @available(iOS 9.0, *)
    open override func allowedChildrenForUnwinding(from source: UIStoryboardUnwindSegueSource) -> [UIViewController] {
        
        if self.children.count > 1 {
            return self.children.dropLast().reversed()
        }
        return []
    }
    @IBAction open func unwindSwapage(for unwindSegue: UIStoryboardSegue) {
        self.popViewControllerAnimated(true)
    }
    @IBAction open func unwindSwapageToRoot(for unwindSegue: UIStoryboardSegue) {
        self.popToRootViewControllerAnimated(true)
    }
    open override func unwind(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
        
        if self.children.contains(subsequentVC) {
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
        if let swappage = source as? SDSwappageController, swappage.children.count == 0 && identifier == SDSwappageController.rootViewControllerIdentifier {
            swappage.addChild(destination)
            swappage.setNeedsStatusBarAppearanceUpdate()
        } else {
            source.swappage?.pushViewController(destination, animated: true)
        }
    }
}
