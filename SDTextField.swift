//
//  SDTextField.swift
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

public protocol SDTextFieldDelegate : UITextFieldDelegate {
    
    func textFieldKeyboardWillShow(textField: SDTextField, animationDuration: Double, animationCurve: UIViewAnimationCurve, startFrame: CGRect, endFrame: CGRect)
    func textFieldKeyboardDidShow(textField: SDTextField, frame: CGRect)
    func textFieldKeyboardWillHide(textField: SDTextField, animationDuration: Double, animationCurve: UIViewAnimationCurve, startFrame: CGRect, endFrame: CGRect)
    func textFieldKeyboardDidHide(textField: SDTextField, frame: CGRect)
    func textFieldKeyboardWillChangeFrame(textField: SDTextField, animationDuration: Double, animationCurve: UIViewAnimationCurve, startFrame: CGRect, endFrame: CGRect)
    func textFieldKeyboardDidChangeFrame(textField: SDTextField, frame: CGRect)
    
    func textFieldDidChanged(textField: SDTextField)
}

public extension SDTextFieldDelegate {
    
    func textFieldKeyboardWillShow(textField: SDTextField, animationDuration: Double, animationCurve: UIViewAnimationCurve, startFrame: CGRect, endFrame: CGRect) {
        // do nothing
    }
    func textFieldKeyboardDidShow(textField: SDTextField, frame: CGRect) {
        // do nothing
    }
    func textFieldKeyboardWillHide(textField: SDTextField, animationDuration: Double, animationCurve: UIViewAnimationCurve, startFrame: CGRect, endFrame: CGRect) {
        // do nothing
    }
    func textFieldKeyboardDidHide(textField: SDTextField, frame: CGRect) {
        // do nothing
    }
    func textFieldKeyboardWillChangeFrame(textField: SDTextField, animationDuration: Double, animationCurve: UIViewAnimationCurve, startFrame: CGRect, endFrame: CGRect) {
        // do nothing
    }
    func textFieldKeyboardDidChangeFrame(textField: SDTextField, frame: CGRect) {
        // do nothing
    }
    
    func textFieldDidChanged(textField: SDTextField) {
        // do nothing
    }
}

@objc
public class SDTextField: UITextField {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(_textFieldKeyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(_textFieldKeyboardDidShow), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(_textFieldKeyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(_textFieldKeyboardDidHide), name: UIKeyboardDidHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(_textFieldKeyboardWillChangeFrame), name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(_textFieldKeyboardDidChangeFrame), name: UIKeyboardDidChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(_textFieldDidChanged), name: UITextFieldTextDidChangeNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidChangeNotification, object: nil)
    }
}

extension SDTextField {
    
    private var _delegate : SDTextFieldDelegate? {
        return self.delegate as? SDTextFieldDelegate
    }
    
    func _textFieldKeyboardWillShow(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo else { return }
        guard let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber else { return }
        guard let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber else { return }
        guard let startFrame = userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue else { return }
        guard let endFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }
        if self.isFirstResponder() {
            _delegate?.textFieldKeyboardWillShow(self, animationDuration: duration.doubleValue, animationCurve: UIViewAnimationCurve(rawValue: curve.longValue)!, startFrame: startFrame.CGRectValue(), endFrame: endFrame.CGRectValue())
        }
    }
    func _textFieldKeyboardDidShow(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo else { return }
        guard let endFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }
        if self.isFirstResponder() {
            _delegate?.textFieldKeyboardDidShow(self, frame: endFrame.CGRectValue())
        }
    }
    func _textFieldKeyboardWillHide(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo else { return }
        guard let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber else { return }
        guard let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber else { return }
        guard let startFrame = userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue else { return }
        guard let endFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }
        if self.isFirstResponder() {
            _delegate?.textFieldKeyboardWillHide(self, animationDuration: duration.doubleValue, animationCurve: UIViewAnimationCurve(rawValue: curve.longValue)!, startFrame: startFrame.CGRectValue(), endFrame: endFrame.CGRectValue())
        }
    }
    func _textFieldKeyboardDidHide(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo else { return }
        guard let endFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }
        _delegate?.textFieldKeyboardDidHide(self, frame: endFrame.CGRectValue())
    }
    func _textFieldKeyboardWillChangeFrame(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo else { return }
        guard let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber else { return }
        guard let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber else { return }
        guard let startFrame = userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue else { return }
        guard let endFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }
        if self.isFirstResponder() {
            _delegate?.textFieldKeyboardWillChangeFrame(self, animationDuration: duration.doubleValue, animationCurve: UIViewAnimationCurve(rawValue: curve.longValue)!, startFrame: startFrame.CGRectValue(), endFrame: endFrame.CGRectValue())
        }
    }
    func _textFieldKeyboardDidChangeFrame(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo else { return }
        guard let endFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }
        _delegate?.textFieldKeyboardDidChangeFrame(self, frame: endFrame.CGRectValue())
    }
    
    func _textFieldDidChanged(notification: NSNotification) {
        if self.isFirstResponder() {
            _delegate?.textFieldDidChanged(self)
        }
    }
}
