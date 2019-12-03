//
//  SDPickerView.swift
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
public protocol SDPickerViewDelegate : AnyObject {
    
    func rowHeight(in pickerView: SDPickerView) -> CGFloat
    
    func viewToPresent(in pickerView: SDPickerView, reusing view: UIView?) -> UIView
    
    func pickerView(_ pickerView: SDPickerView, titleForRow row: Int) -> String?
    
    func pickerView(_ pickerView: SDPickerView, attributedTitleForRow row: Int) -> NSAttributedString?
    
    func pickerView(_ pickerView: SDPickerView, viewForRow row: Int, reusing view: UIView?) -> UIView
    
    func pickerView(_ pickerView: SDPickerView, didSelectRow row: Int)
}

@available(iOS 11.0, *)
extension SDPickerViewDelegate {
    
    public func rowHeight(in pickerView: SDPickerView) -> CGFloat {
        return 44
    }
    
    public func viewToPresent(in pickerView: SDPickerView, reusing view: UIView?) -> UIView {
        return self.pickerView(pickerView, viewForRow: pickerView.selectedRow, reusing: view)
    }
    
    public func pickerView(_ pickerView: SDPickerView, titleForRow row: Int) -> String? {
        return nil
    }
    
    public func pickerView(_ pickerView: SDPickerView, attributedTitleForRow row: Int) -> NSAttributedString? {
        return self.pickerView(pickerView, titleForRow: row).map { NSAttributedString(string: $0) }
    }
    
    public func pickerView(_ pickerView: SDPickerView, viewForRow row: Int, reusing view: UIView?) -> UIView {
        
        let view = view ?? UIView()
        
        let label = view.subviews.first as? UILabel ?? UILabel()
        label.attributedText = self.pickerView(pickerView, attributedTitleForRow: row)
        
        view.subviews.first?.removeFromSuperview()
        view.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[label]|", options: [], metrics: nil, views: ["label": label]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-|", options: [], metrics: nil, views: ["label": label]))
        
        return view
    }
    
    public func pickerView(_ pickerView: SDPickerView, didSelectRow row: Int) {
        
    }
}

@available(iOS 11.0, *)
public protocol SDPickerViewDataSource : AnyObject {
    
    func numberOfRows(in pickerView: SDPickerView) -> Int
}

@available(iOS 11.0, *)
@IBDesignable open class SDPickerView : UIControl {
    
    private let contentView = UIView()
    private let button = UIButton(type: .custom)
    
    open weak var delegate: SDPickerViewDelegate? {
        didSet {
            self.reloadData()
        }
    }
    
    open weak var dataSource: SDPickerViewDataSource? {
        didSet {
            self.reloadData()
        }
    }
    
    @IBInspectable open var pickerSize: CGSize = CGSize(width: 214, height: 280)
    
    @IBInspectable open var pickerBackgroundColor: UIColor? = DEFAULT_BACKGROUND_COLOR
    
    open var selectedRow: Int = 0 {
        didSet {
            self.reloadData()
        }
    }
    
    open var numberOfRows: Int {
        return dataSource?.numberOfRows(in: self) ?? 0
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
        picker.popoverPresentationController?.delegate = picker
        picker.popoverPresentationController?.permittedArrowDirections = [.up, .down]
        
        if var viewController = self.window?.rootViewController {
            
            while true {
                
                if let presentedViewController = viewController.presentedViewController {
                    
                    viewController = presentedViewController
                    
                } else if let navigationController = viewController as? UINavigationController, let visibleViewController = navigationController.visibleViewController {
                    
                    viewController = visibleViewController
                    
                } else if let tabBarController = viewController as? UITabBarController, let selectedViewController = tabBarController.selectedViewController {
                    
                    viewController = selectedViewController
                    
                } else {
                    
                    viewController.present(picker, animated: true, completion: nil)
                    return
                }
            }
        }
    }
    
    open func reloadData() {
        
        let reusing = self.contentView.subviews.first
        reusing?.removeFromSuperview()
        
        if 0..<numberOfRows ~= selectedRow, let view = self.delegate?.viewToPresent(in: self, reusing: reusing) {
            
            self.contentView.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: ["view": view]))
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: ["view": view]))
        }
    }
}

@available(iOS 11.0, *)
private class SDPickerController : UITableViewController, UIPopoverPresentationControllerDelegate {
    
    weak var delegate: SDPickerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = delegate?.pickerBackgroundColor
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.separatorStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate?.numberOfRows ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.delegate.flatMap { $0.delegate?.rowHeight(in: $0) } ?? 44
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.accessoryType = self.delegate?.selectedRow == indexPath.row ? .checkmark : .none
        
        if let picker = self.delegate {
            
            let reusing = cell.contentView.subviews.first
            reusing?.removeFromSuperview()
            
            if let view = picker.delegate?.pickerView(picker, viewForRow: indexPath.row, reusing: reusing) {
                
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
        
        delegate.selectedRow = indexPath.row
        tableView.selectRow(at: nil, animated: false, scrollPosition: .none)
        
        for cell in tableView.visibleCells {
            guard let indexPath = tableView.indexPath(for: cell) else { continue }
            cell.accessoryType = delegate.selectedRow == indexPath.row ? .checkmark : .none
        }
        
        delegate.sendActions(for: .valueChanged)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
