//
//  SDNumberField.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2019 Susan Cheng. All rights reserved.
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

@available(iOS 11.0, *)
@IBDesignable open class SDNumberField : UIControl {
    
    private let button = UIButton(type: .custom)
    
    fileprivate var _text: String = "0" {
        didSet {
            button.setTitle(_text, for: .normal)
        }
    }
    
    @IBInspectable open var value: CGFloat {
        get {
            return Decimal(string: _text).map { CGFloat(NSDecimalNumber(decimal: $0).doubleValue) } ?? 0
        }
        set {
            _text = "\(Decimal(Double(newValue)))"
        }
    }
    
    @IBInspectable open var isDecimal: Bool = true
    
    @IBInspectable open var keyboardBackgroundColor: UIColor? = {
        if #available(iOS 13.0, *) {
            return UIColor.systemBackground
        } else {
            return UIColor.white
        }
    }()
    
    @IBInspectable open var keyboardButtonBackgroundColor: UIColor? = {
        if #available(iOS 13.0, *) {
            return UIColor.systemBackground
        } else {
            return UIColor.white
        }
    }()
    
    @IBInspectable open var keyboardLabelColor: UIColor? = {
        if #available(iOS 13.0, *) {
            return UIColor.label
        } else {
            return UIColor.black
        }
    }()
    
    @IBInspectable open var keyboardButtonCornerRadius: CGFloat = 0
    
    @IBInspectable open var keyboardButtonBorderWidth: CGFloat = 0
    
    @IBInspectable open var keyboardButtonBorderColor: UIColor?
    
    open override var isEnabled: Bool  {
        get {
            return button.isEnabled
        }
        set {
            button.isEnabled = newValue
        }
    }
    
    open override var contentHorizontalAlignment: UIControl.ContentHorizontalAlignment {
        get {
            return button.contentHorizontalAlignment
        }
        set {
            button.contentHorizontalAlignment = newValue
        }
    }
    
    open override var contentVerticalAlignment: UIControl.ContentVerticalAlignment {
        get {
            return button.contentVerticalAlignment
        }
        set {
            button.contentVerticalAlignment = newValue
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self._init()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self._init()
    }
    
    func _init() {
        
        self.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[button]|", options: [], metrics: nil, views: ["button": button]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[button]|", options: [], metrics: nil, views: ["button": button]))
        
        button.setTitle(_text, for: .normal)
        if #available(iOS 13.0, *) {
            button.setTitleColor(UIColor.label, for: .normal)
        } else {
            button.setTitleColor(UIColor.black, for: .normal)
        }
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    }
    
    @objc func buttonAction(_ sender: Any) {
        
        let keyboard = SDNumberFieldKeyboard()
        keyboard.delegate = self
        
        keyboard.preferredContentSize = CGSize(width: 214, height: 280)
        keyboard.modalPresentationStyle = .popover
        keyboard.popoverPresentationController?.sourceView = self
        keyboard.popoverPresentationController?.delegate = keyboard
        
        if var viewController = self.window?.rootViewController {
            
            while true {
                
                if let presentedViewController = viewController.presentedViewController {
                    
                    viewController = presentedViewController
                    
                } else if let navigationController = viewController as? UINavigationController {
                    
                    viewController = navigationController.visibleViewController ?? navigationController
                    
                } else if let tabBarController = viewController as? UITabBarController {
                    
                    viewController = tabBarController.selectedViewController ?? tabBarController
                    
                } else if let childViewControllers = viewController.children.last {
                    
                    viewController = childViewControllers
                    
                } else {
                    
                    viewController.present(keyboard, animated: true, completion: nil)
                    return
                }
            }
        }
    }
}

@available(iOS 11.0, *)
private class SDNumberFieldKeyboard : UIViewController, UIPopoverPresentationControllerDelegate {
    
    weak var delegate: SDNumberField?
    
    var old_value: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = delegate?.keyboardBackgroundColor
        
        let container = UIView()
        self.view.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        var buttons: [UIButton] = []
        
        func _set_button(_ button: UIButton) {
            button.backgroundColor = delegate?.keyboardButtonBackgroundColor
            button.setTitleColor(delegate?.keyboardLabelColor, for: .normal)
            button.tintColor = delegate?.keyboardLabelColor
            button.cornerRadius = delegate?.keyboardButtonCornerRadius ?? 0
            button.borderWidth = delegate?.keyboardButtonBorderWidth ?? 0
            button.borderColor = delegate?.keyboardButtonBorderColor
            button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        }
        
        for i in 0..<10 {
            let button = UIButton(type: .custom)
            button.tag = i
            button.setTitle("\(i)", for: .normal)
            _set_button(button)
            buttons.append(button)
            container.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
        }
        
        if delegate?.isDecimal == true {
            let button = UIButton(type: .custom)
            button.tag = 10
            button.setTitle(".", for: .normal)
            _set_button(button)
            buttons.append(button)
            container.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
        }
        
        do {
            let button = UIButton(type: .custom)
            button.tag = 11
            if #available(iOS 13.0, *) {
                button.setImage(UIImage(systemName: "delete.left"), for: .normal)
            } else {
                button.setTitle("DEL", for: .normal)
            }
            _set_button(button)
            buttons.append(button)
            container.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            self.view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 0),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 0),
            self.view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: container.topAnchor, constant: 0),
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0),
        ])
        
        NSLayoutConstraint.activate(buttons.dropFirst(2).map { NSLayoutConstraint(item: buttons[1], attribute: .width, relatedBy: .equal, toItem: $0, attribute: .width, multiplier: 1, constant: 0) })
        NSLayoutConstraint.activate(buttons.dropFirst().map { NSLayoutConstraint(item: buttons[0], attribute: .height, relatedBy: .equal, toItem: $0, attribute: .height, multiplier: 1, constant: 0) })
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[button1]-16-[button2]-16-[button3]-16-|", options: [], metrics: nil, views: ["button1": buttons[1], "button2": buttons[2], "button3": buttons[3]]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[button1]-16-[button2]-16-[button3]-16-|", options: [], metrics: nil, views: ["button1": buttons[4], "button2": buttons[5], "button3": buttons[6]]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[button1]-16-[button2]-16-[button3]-16-|", options: [], metrics: nil, views: ["button1": buttons[7], "button2": buttons[8], "button3": buttons[9]]))
        
        if delegate?.isDecimal == true {
            
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[button1]-16-[button2]-16-[button3]-16-|", options: [], metrics: nil, views: ["button1": buttons[0], "button2": buttons[10], "button3": buttons[11]]))
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[button1]-16-[button2]-16-[button3]-16-[button4]-16-|", options: [], metrics: nil, views: ["button1": buttons[7], "button2": buttons[4], "button3": buttons[1], "button4": buttons[0]]))
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[button1]-16-[button2]-16-[button3]-16-[button4]-16-|", options: [], metrics: nil, views: ["button1": buttons[8], "button2": buttons[5], "button3": buttons[2], "button4": buttons[10]]))
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[button1]-16-[button2]-16-[button3]-16-[button4]-16-|", options: [], metrics: nil, views: ["button1": buttons[9], "button2": buttons[6], "button3": buttons[3], "button4": buttons[11]]))
            
        } else {
            
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[button1]-16-[button2]-16-|", options: [], metrics: nil, views: ["button1": buttons[0], "button2": buttons[10]]))
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[button1]-16-[button2]-16-[button3]-16-[button4]-16-|", options: [], metrics: nil, views: ["button1": buttons[7], "button2": buttons[4], "button3": buttons[1], "button4": buttons[0]]))
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[button1]-16-[button2]-16-[button3]-16-[button4]-16-|", options: [], metrics: nil, views: ["button1": buttons[8], "button2": buttons[5], "button3": buttons[2], "button4": buttons[0]]))
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[button1]-16-[button2]-16-[button3]-16-[button4]-16-|", options: [], metrics: nil, views: ["button1": buttons[9], "button2": buttons[6], "button3": buttons[3], "button4": buttons[10]]))
            
        }
    }
    
    @objc func buttonAction(_ sender: UIButton) {
        
        guard let delegate = self.delegate else { return }
        
        if old_value == nil {
            old_value = delegate._text
            delegate._text = ""
        }
        
        switch sender.tag {
        case 10:
            if !delegate._text.contains(".") {
                delegate._text += "."
            }
        case 11:
            if !delegate._text.isEmpty {
                delegate._text.removeLast()
            }
        default: delegate._text += "\(sender.tag)"
        }
        
        delegate.sendActions(for: .valueChanged)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        
        guard let delegate = self.delegate else { return }
        
        if delegate._text.isEmpty {
            
            delegate._text = old_value ?? "0"
            delegate.sendActions(for: .valueChanged)
            
        } else if let decimal = Decimal(string: delegate._text), delegate._text != "\(decimal)" {
            
            delegate._text = "\(decimal)"
            delegate.sendActions(for: .valueChanged)
        }
    }
}
