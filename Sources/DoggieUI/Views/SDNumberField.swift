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
    
    @IBInspectable open var labelColor: UIColor? = DEFAULT_LABEL_COLOR {
        didSet {
            button.setTitleColor(labelColor, for: .normal)
        }
    }
    
    @IBInspectable open var keyboardSize: CGSize = CGSize(width: 214, height: 280)
    
    @IBInspectable open var keyboardBackgroundColor: UIColor? = DEFAULT_BACKGROUND_COLOR
    
    @IBInspectable open var keyButtonBackgroundColor: UIColor? = DEFAULT_BACKGROUND_COLOR
    
    @IBInspectable open var keyLabelColor: UIColor? = DEFAULT_LABEL_COLOR
    
    @IBInspectable open var keyButtonSpacing: CGFloat = 8
    
    @IBInspectable open var keyButtonCornerRadius: CGFloat = 0
    
    @IBInspectable open var keyButtonBorderWidth: CGFloat = 0
    
    @IBInspectable open var keyButtonBorderColor: UIColor?
    
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
    
    private func _init() {
        
        self.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[button]|", options: [], metrics: nil, views: ["button": button]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[button]|", options: [], metrics: nil, views: ["button": button]))
        
        button.setTitle(_text, for: .normal)
        button.setTitleColor(labelColor, for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    }
    
    @objc func buttonAction(_ sender: Any) {
        
        let keyboard = SDNumberFieldKeyboard()
        keyboard.delegate = self
        
        keyboard.preferredContentSize = keyboardSize
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
        
        var buttons: [UIButton] = []
        
        func _set_button(_ button: UIButton) {
            button.backgroundColor = delegate?.keyButtonBackgroundColor
            button.setTitleColor(delegate?.keyLabelColor, for: .normal)
            button.cornerRadius = delegate?.keyButtonCornerRadius ?? 0
            button.borderWidth = delegate?.keyButtonBorderWidth ?? 0
            button.borderColor = delegate?.keyButtonBorderColor
            button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        }
        
        for i in 0..<10 {
            let button = UIButton(type: .custom)
            button.tag = i
            button.setTitle("\(i)", for: .normal)
            _set_button(button)
            buttons.append(button)
        }
        
        if delegate?.isDecimal == true {
            let button = UIButton(type: .custom)
            button.tag = 10
            button.setTitle(".", for: .normal)
            _set_button(button)
            buttons.append(button)
        }
        
        do {
            let button = UIButton(type: .custom)
            button.tag = 11
            button.setTitle("⌫", for: .normal)
            _set_button(button)
            buttons.append(button)
        }
        
        let h_stack_1 = UIStackView(arrangedSubviews: [buttons[7], buttons[8], buttons[9]])
        let h_stack_2 = UIStackView(arrangedSubviews: [buttons[4], buttons[5], buttons[6]])
        let h_stack_3 = UIStackView(arrangedSubviews: [buttons[1], buttons[2], buttons[3]])
        let h_stack_4 = UIStackView(arrangedSubviews: delegate?.isDecimal == true ? [buttons[10], buttons[0], buttons[11]] : [buttons[0], buttons[10]])
        
        h_stack_1.spacing = delegate?.keyButtonSpacing ?? 0
        h_stack_2.spacing = delegate?.keyButtonSpacing ?? 0
        h_stack_3.spacing = delegate?.keyButtonSpacing ?? 0
        h_stack_4.spacing = delegate?.keyButtonSpacing ?? 0
        
        let stack = UIStackView(arrangedSubviews: [h_stack_1, h_stack_2, h_stack_3, h_stack_4])
        
        stack.spacing = delegate?.keyButtonSpacing ?? 0
        stack.axis = .vertical
        
        self.view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: delegate?.keyButtonSpacing ?? 0),
            stack.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: delegate?.keyButtonSpacing ?? 0),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: stack.trailingAnchor, constant: delegate?.keyButtonSpacing ?? 0),
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: stack.bottomAnchor, constant: delegate?.keyButtonSpacing ?? 0),
        ])
        
        NSLayoutConstraint.activate(buttons.dropFirst(2).map { NSLayoutConstraint(item: buttons[1], attribute: .width, relatedBy: .equal, toItem: $0, attribute: .width, multiplier: 1, constant: 0) })
        NSLayoutConstraint.activate(buttons.dropFirst().map { NSLayoutConstraint(item: buttons[0], attribute: .height, relatedBy: .equal, toItem: $0, attribute: .height, multiplier: 1, constant: 0) })

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
