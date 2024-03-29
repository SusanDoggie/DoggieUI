//
//  SDNumberField.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2024 Susan Cheng. All rights reserved.
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#if os(iOS)

import UIKit

extension Decimal {
    
    fileprivate func rounded(scale: Int = 0, roundingMode: NSDecimalNumber.RoundingMode = .plain) -> Decimal {
        var x = self
        var result = Decimal()
        NSDecimalRound(&result, &x, scale, roundingMode)
        return result
    }
}

@IBDesignable open class SDNumberField: UIControl {
    
    private let button = UIButton(type: .custom)
    
    private weak var keyboard: SDNumberFieldKeyboard?
    
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
            _text = "\(Decimal(Double(newValue)).rounded(scale: decimalRoundingPlaces))"
        }
    }
    
    @IBInspectable open var decimalRoundingPlaces: Int = 9
    
    @IBInspectable open var isSigned: Bool = true
    
    @IBInspectable open var isDecimal: Bool = true
    
    @IBInspectable open var labelColor: UIColor? = DEFAULT_LABEL_COLOR {
        didSet {
            button.setTitleColor(labelColor, for: .normal)
        }
    }
    
    @IBInspectable open var keyboardSize: CGSize = CGSize(width: 214, height: 346)
    
    @IBInspectable open var keyboardBackgroundColor: UIColor? = DEFAULT_BACKGROUND_COLOR
    
    @IBInspectable open var keyButtonBackgroundColor: UIColor? = DEFAULT_BACKGROUND_COLOR
    
    @IBInspectable open var keyLabelColor: UIColor? = DEFAULT_LABEL_COLOR
    
    @IBInspectable open var keyButtonSpacing: CGFloat = 8
    
    @IBInspectable open var keyButtonCornerRadius: CGFloat = 0
    
    @IBInspectable open var keyButtonBorderWidth: CGFloat = 0
    
    @IBInspectable open var keyButtonBorderColor: UIColor?
    
    #if os(iOS)
    
    @IBInspectable open var enablePointerInteraction: Bool = false
    
    var _pointerStyleProvider: Any?
    
    @available(iOS 13.4, macCatalyst 13.4, *)
    open var pointerStyleProvider: UIButton.PointerStyleProvider? {
        get {
            return _pointerStyleProvider as? UIButton.PointerStyleProvider
        }
        set {
            _pointerStyleProvider = newValue
        }
    }
    
    #endif
    
    open var lineBreakMode: NSLineBreakMode {
        get {
            return button.titleLabel?.lineBreakMode ?? .byTruncatingTail
        }
        set {
            button.titleLabel?.lineBreakMode = newValue
        }
    }
    
    @IBInspectable open var adjustsFontSizeToFitWidth: Bool {
        get {
            return button.titleLabel?.adjustsFontSizeToFitWidth ?? false
        }
        set {
            button.titleLabel?.adjustsFontSizeToFitWidth = newValue
        }
    }
    
    @IBInspectable open var minimumScaleFactor: CGFloat {
        get {
            return button.titleLabel?.minimumScaleFactor ?? 0
        }
        set {
            button.titleLabel?.minimumScaleFactor = newValue
        }
    }
    
    @IBInspectable open var allowsDefaultTighteningForTruncation: Bool {
        get {
            return button.titleLabel?.allowsDefaultTighteningForTruncation ?? false
        }
        set {
            button.titleLabel?.allowsDefaultTighteningForTruncation = newValue
        }
    }
    
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
        keyboard.popoverPresentationController?.sourceRect = self.bounds
        keyboard.popoverPresentationController?.delegate = keyboard
        keyboard.popoverPresentationController?.permittedArrowDirections = [.up, .down]
        
        self.keyboard = keyboard
        
        if var viewController = self.window?.rootViewController {
            
            while true {
                
                if let presentedViewController = viewController.presentedViewController {
                    
                    viewController = presentedViewController
                    
                } else if let navigationController = viewController as? UINavigationController, let visibleViewController = navigationController.visibleViewController {
                    
                    viewController = visibleViewController
                    
                } else if let tabBarController = viewController as? UITabBarController, let selectedViewController = tabBarController.selectedViewController {
                    
                    viewController = selectedViewController
                    
                } else {
                    
                    viewController.present(keyboard, animated: true, completion: nil)
                    self.sendActions(for: .editingDidBegin)
                    return
                }
            }
        }
    }
    
    open func endEditing() {
        self.keyboard?._endEditing()
        self.keyboard?.dismiss(animated: true, completion: nil)
    }
}

private class SDNumberFieldKeyboard: UIViewController, UIPopoverPresentationControllerDelegate {
    
    weak var delegate: SDNumberField?
    
    let label = UILabel()
    
    var old_value: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = delegate?.keyboardBackgroundColor
        
        label.text = delegate?._text
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        
        let label_container = UIView()
        
        label.textColor = delegate?.keyLabelColor
        label_container.backgroundColor = delegate?.keyButtonBackgroundColor
        label_container.cornerRadius = delegate?.keyButtonCornerRadius ?? 0
        label_container.borderWidth = delegate?.keyButtonBorderWidth ?? 0
        label_container.borderColor = delegate?.keyButtonBorderColor
        
        label_container.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[label]|", options: [], metrics: nil, views: ["label": label]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-|", options: [], metrics: nil, views: ["label": label]))
        
        var buttons: [UIButton] = []
        
        func _set_button(_ button: UIButton) {
            button.backgroundColor = delegate?.keyButtonBackgroundColor
            button.setTitleColor(delegate?.keyLabelColor, for: .normal)
            button.cornerRadius = delegate?.keyButtonCornerRadius ?? 0
            button.borderWidth = delegate?.keyButtonBorderWidth ?? 0
            button.borderColor = delegate?.keyButtonBorderColor
            if #available(iOS 13.4, macCatalyst 13.4, *) {
                button.isPointerInteractionEnabled = delegate?.enablePointerInteraction ?? false
                button.pointerStyleProvider = delegate?.pointerStyleProvider
            }
            button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        }
        
        for i in 0..<10 {
            let button = UIButton(type: .custom)
            button.tag = i
            button.setTitle("\(i)", for: .normal)
            _set_button(button)
            buttons.append(button)
        }
        
        do {
            let button = UIButton(type: .custom)
            button.tag = 10
            button.setTitle("⌫", for: .normal)
            _set_button(button)
            buttons.append(button)
        }
        
        var dot_button: UIButton?
        if delegate?.isDecimal == true {
            let button = UIButton(type: .custom)
            button.tag = 11
            button.setTitle(".", for: .normal)
            _set_button(button)
            buttons.append(button)
            dot_button = button
        }
        
        var sign_button: UIButton?
        if delegate?.isSigned == true {
            let button = UIButton(type: .custom)
            button.tag = 12
            button.setTitle("⁺∕₋", for: .normal)
            _set_button(button)
            buttons.append(button)
            sign_button = button
        }
        
        let h_stack_0 = UIStackView(arrangedSubviews: sign_button.map { [$0, label_container] } ?? [label_container])
        let h_stack_1 = UIStackView(arrangedSubviews: [buttons[7], buttons[8], buttons[9]])
        let h_stack_2 = UIStackView(arrangedSubviews: [buttons[4], buttons[5], buttons[6]])
        let h_stack_3 = UIStackView(arrangedSubviews: [buttons[1], buttons[2], buttons[3]])
        let h_stack_4 = UIStackView(arrangedSubviews: dot_button.map { [$0, buttons[0], buttons[10]] } ?? [buttons[0], buttons[10]])
        
        h_stack_0.spacing = delegate?.keyButtonSpacing ?? 0
        h_stack_1.spacing = delegate?.keyButtonSpacing ?? 0
        h_stack_2.spacing = delegate?.keyButtonSpacing ?? 0
        h_stack_3.spacing = delegate?.keyButtonSpacing ?? 0
        h_stack_4.spacing = delegate?.keyButtonSpacing ?? 0
        
        let stack = UIStackView(arrangedSubviews: [h_stack_0, h_stack_1, h_stack_2, h_stack_3, h_stack_4])
        
        stack.spacing = delegate?.keyButtonSpacing ?? 0
        stack.axis = .vertical
        stack.distribution = .fillEqually
        
        self.view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: delegate?.keyButtonSpacing ?? 0),
            stack.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: delegate?.keyButtonSpacing ?? 0),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: stack.trailingAnchor, constant: delegate?.keyButtonSpacing ?? 0),
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: stack.bottomAnchor, constant: delegate?.keyButtonSpacing ?? 0),
        ])
        
        NSLayoutConstraint.activate(buttons.dropFirst(2).map { NSLayoutConstraint(item: $0, attribute: .width, relatedBy: .equal, toItem: buttons[1], attribute: .width, multiplier: 1, constant: 0) })
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.resignFirstResponder()
    }
    
    func _endEditing() {
        
        guard let delegate = self.delegate else { return }
        
        if delegate._text.isEmpty {
            
            delegate._text = old_value ?? "0"
            delegate.sendActions(for: .editingChanged)
            
        } else if let decimal = Decimal(string: delegate._text), delegate._text != "\(decimal)" {
            
            delegate._text = "\(decimal)"
            delegate.sendActions(for: .editingChanged)
        }
        
        delegate.sendActions(for: .editingDidEnd)
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        
        for press in presses {
            
            guard let key = press.key else { continue }
            
            let inputs = key.charactersIgnoringModifiers
            
            switch inputs {
                
            case "\u{8}": self.inputCommandAction(inputs)
            case "0"..."9": self.inputCommandAction(inputs)
                
            case ".":
                
                if delegate?.isDecimal == true {
                    self.inputCommandAction(inputs)
                }
                
            case "-":
                
                if delegate?.isSigned == true {
                    self.inputCommandAction(inputs)
                }
                
            case "\r":
                
                self._endEditing()
                self.dismiss(animated: true, completion: nil)
                
            default: break
            }
        }
    }
    
    @objc func buttonAction(_ sender: UIButton) {
        
        switch sender.tag {
        case 10: self.inputCommandAction("\u{8}")
        case 11: self.inputCommandAction(".")
        case 12: self.inputCommandAction("-")
        default: self.inputCommandAction("\(sender.tag)")
        }
    }
    
    func inputCommandAction(_ key: String) {
        
        guard let delegate = self.delegate else { return }
        
        if old_value == nil {
            old_value = delegate._text
            if key != "-" {
                delegate._text = ""
            }
        }
        
        switch key {
        case "\u{8}":
            if !delegate._text.isEmpty {
                delegate._text.removeLast()
            }
        case ".":
            if delegate._text.isEmpty {
                delegate._text = "0."
            } else if !delegate._text.contains(".") {
                delegate._text += "."
            }
        case "-":
            if delegate._text.first == "-" {
                delegate._text.removeFirst()
            } else {
                delegate._text = "-" + delegate._text
            }
        case "0"..."9": delegate._text += key
        default: break
        }
        
        label.text = delegate._text
        delegate.sendActions(for: .editingChanged)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        self._endEditing()
    }
}

#endif
