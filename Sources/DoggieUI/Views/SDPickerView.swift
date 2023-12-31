//
//  SDPickerView.swift
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

@objc public protocol SDPickerViewDelegate: AnyObject {
    
    @objc optional func rowHeight(in pickerView: SDPickerView) -> CGFloat
    
    @objc optional func pickerViewWillShow(_ pickerView: SDPickerView)
    
    @objc optional func pickerViewDidShow(_ pickerView: SDPickerView)
    
    @objc optional func pickerView(_ pickerView: SDPickerView, titleForHeaderInSection section: Int) -> String?
    
    @objc optional func pickerView(_ pickerView: SDPickerView, titleForFooterInSection section: Int) -> String?
    
    @objc optional func pickerView(_ pickerView: SDPickerView, titleForRow indexPath: IndexPath) -> String?
    
    @objc optional func pickerView(_ pickerView: SDPickerView, attributedTitleForRow indexPath: IndexPath) -> NSAttributedString?
    
    @objc optional func pickerView(_ pickerView: SDPickerView, viewForRow indexPath: IndexPath, reusing view: UIView?) -> UIView
    
    @objc optional func pickerView(_ pickerView: SDPickerView, viewForPresentInRow indexPath: IndexPath, reusing view: UIView?) -> UIView
    
    @objc optional func pickerView(_ pickerView: SDPickerView, didSelectRow indexPath: IndexPath)
}

extension SDPickerViewDelegate {
    
    fileprivate func _pickerView(_ pickerView: SDPickerView, attributedTitleForRow indexPath: IndexPath) -> NSAttributedString? {
        if let function = self.pickerView(_:attributedTitleForRow:) {
            return function(pickerView, indexPath)
        }
        return self.pickerView?(pickerView, titleForRow: indexPath).map { NSAttributedString(string: $0) }
    }
    
    fileprivate func _pickerView(_ pickerView: SDPickerView, viewForRow indexPath: IndexPath, reusing view: UIView?) -> UIView {
        
        if let function = self.pickerView(_:viewForRow:reusing:) {
            return function(pickerView, indexPath, view)
        }
        
        let view = view ?? UIView()
        
        let label = view.subviews.first as? UILabel ?? UILabel()
        label.attributedText = self._pickerView(pickerView, attributedTitleForRow: indexPath)
        
        view.subviews.first?.removeFromSuperview()
        view.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[label]|", options: [], metrics: nil, views: ["label": label]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-|", options: [], metrics: nil, views: ["label": label]))
        
        return view
    }
    
    fileprivate func _pickerView(_ pickerView: SDPickerView, viewForPresentInRow indexPath: IndexPath, reusing view: UIView?) -> UIView {
        if let function = self.pickerView(_:viewForPresentInRow:reusing:) {
            return function(pickerView, indexPath, view)
        }
        return self._pickerView(pickerView, viewForRow: indexPath, reusing: view)
    }
}

@objc public protocol SDPickerViewDataSource: AnyObject {
    
    @objc optional func numberOfSections(in pickerView: SDPickerView) -> Int
    
    func pickerView(_ pickerView: SDPickerView, numberOfRowsInSection section: Int) -> Int
}

@IBDesignable open class SDPickerView: UIControl {
    
    private let contentView = UIView()
    private let button = UIButton(type: .custom)
    
    private weak var picker: SDPickerController?
    
    @IBOutlet open weak var delegate: SDPickerViewDelegate? {
        didSet {
            self.reloadData()
        }
    }
    
    @IBOutlet open weak var dataSource: SDPickerViewDataSource? {
        didSet {
            self.reloadData()
        }
    }
    
    @IBInspectable open var pickerSize: CGSize = CGSize(width: 214, height: 280)
    
    @IBInspectable open var pickerBackgroundColor: UIColor? = DEFAULT_BACKGROUND_COLOR
    
    @IBInspectable open var pickerHeaderTextColor: UIColor? = DEFAULT_LABEL_COLOR
    
    @IBInspectable open var pickerHeaderBackgroundColor: UIColor? = DEFAULT_BACKGROUND_COLOR
    
    @IBInspectable open var pickerFooterTextColor: UIColor? = DEFAULT_LABEL_COLOR
    
    @IBInspectable open var pickerFooterBackgroundColor: UIColor? = DEFAULT_BACKGROUND_COLOR
    
    open var selectedIndex: IndexPath = IndexPath(row: 0, section: 0) {
        didSet {
            self.reloadData()
        }
    }
    
    open var numberOfSections: Int {
        return dataSource?.numberOfSections?(in: self) ?? 1
    }
    
    open func numberOfRows(in section: Int) -> Int {
        return dataSource?.pickerView(self, numberOfRowsInSection: section) ?? 0
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
        
        self.addSubview(contentView)
        self.addSubview(button)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[content]|", options: [], metrics: nil, views: ["content": contentView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[content]|", options: [], metrics: nil, views: ["content": contentView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[button]|", options: [], metrics: nil, views: ["button": button]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[button]|", options: [], metrics: nil, views: ["button": button]))
        
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    }
    
    @objc func buttonAction(_ sender: Any) {
        
        let picker = SDPickerController(style: .plain)
        picker.delegate = self
        
        picker.preferredContentSize = pickerSize
        picker.modalPresentationStyle = .popover
        picker.popoverPresentationController?.sourceView = self
        picker.popoverPresentationController?.sourceRect = self.bounds
        picker.popoverPresentationController?.delegate = picker
        picker.popoverPresentationController?.permittedArrowDirections = [.up, .down]
        
        self.picker = picker
        
        delegate?.pickerViewWillShow?(self)
        
        if var viewController = self.window?.rootViewController {
            
            while true {
                
                if let presentedViewController = viewController.presentedViewController {
                    
                    viewController = presentedViewController
                    
                } else if let navigationController = viewController as? UINavigationController, let visibleViewController = navigationController.visibleViewController {
                    
                    viewController = visibleViewController
                    
                } else if let tabBarController = viewController as? UITabBarController, let selectedViewController = tabBarController.selectedViewController {
                    
                    viewController = selectedViewController
                    
                } else {
                    
                    viewController.present(picker, animated: true) { [weak self] in self.map { $0.delegate?.pickerViewDidShow?($0) } }
                    return
                }
            }
        }
    }
    
    open func endEditing() {
        self.picker?.dismiss(animated: true, completion: nil)
    }
    
    open func reloadData() {
        
        let reusing = self.contentView.subviews.first
        reusing?.removeFromSuperview()
        
        guard selectedIndex.count == 2 else { return }
        guard 0..<numberOfSections ~= selectedIndex.section else { return }
        guard 0..<numberOfRows(in: selectedIndex.section) ~= selectedIndex.row else { return }
        
        if let view = self.delegate?._pickerView(self, viewForPresentInRow: selectedIndex, reusing: reusing) {
            
            self.contentView.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: ["view": view]))
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: ["view": view]))
        }
    }
}

private class SDPickerController: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    weak var delegate: SDPickerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = delegate?.pickerBackgroundColor
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.separatorStyle = .none
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return delegate?.numberOfSections ?? 0
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        view.tintColor = delegate?.pickerHeaderBackgroundColor ?? .clear
        header.textLabel?.textColor = delegate?.pickerHeaderTextColor ?? .clear
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        view.tintColor = delegate?.pickerFooterBackgroundColor ?? .clear
        header.textLabel?.textColor = delegate?.pickerFooterTextColor ?? .clear
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let delegate = self.delegate else { return nil }
        return delegate.delegate?.pickerView?(delegate, titleForHeaderInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let delegate = self.delegate else { return nil }
        return delegate.delegate?.pickerView?(delegate, titleForFooterInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate?.numberOfRows(in: section) ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.delegate.flatMap { $0.delegate?.rowHeight?(in: $0) } ?? 44
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.accessoryType = self.delegate?.selectedIndex == indexPath ? .checkmark : .none
        
        if let picker = self.delegate {
            
            let reusing = cell.contentView.subviews.first
            reusing?.removeFromSuperview()
            
            if let view = picker.delegate?._pickerView(picker, viewForRow: indexPath, reusing: reusing) {
                
                cell.contentView.addSubview(view)
                view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: ["view": view]))
                NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: ["view": view]))
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let delegate = self.delegate else { return }
        
        delegate.selectedIndex = indexPath
        tableView.selectRow(at: nil, animated: false, scrollPosition: .none)
        
        for cell in tableView.visibleCells {
            guard let indexPath = tableView.indexPath(for: cell) else { continue }
            cell.accessoryType = delegate.selectedIndex == indexPath ? .checkmark : .none
        }
        
        delegate.sendActions(for: .valueChanged)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

#endif
