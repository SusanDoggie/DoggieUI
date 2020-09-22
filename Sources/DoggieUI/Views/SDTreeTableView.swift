//
//  SDTreeTableView.swift
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

extension Sequence {
    
    fileprivate func min<R: Comparable>(by: (Element) throws -> R) rethrows -> Element? {
        return try self.min { try by($0) < by($1) }
    }
}

extension CGRect {
    
    fileprivate var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}

open class SDTreeTableView: UITableView {
    
    open var expanded: Set<IndexPath> = []
    
    open override var dataSource: UITableViewDataSource? {
        get {
            return super.dataSource
        }
        set {
            super.dataSource = newValue as? SDTreeTableViewDataSource
        }
    }
    
    private lazy var dropInsertionView: UIView = {
        let view = UIView(frame: CGRect())
        view.backgroundColor = UIColor.systemBlue
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        self.addSubview(view)
        return view
    }()
    
    private var dropInsertionViewConstraints: [NSLayoutConstraint] = [] {
        didSet {
            if !oldValue.isEmpty {
                NSLayoutConstraint.deactivate(oldValue)
            }
            if !dropInsertionViewConstraints.isEmpty {
                NSLayoutConstraint.activate(dropInsertionViewConstraints)
            }
        }
    }
    
    private lazy var dragInteraction: UIDragInteraction = {
        
        let interaction = UIDragInteraction(delegate: self)
        interaction.isEnabled = false
        
        self.addInteraction(interaction)
        self.addInteraction(UIDropInteraction(delegate: self))
        
        if let longPressRecognizer = gestureRecognizers?.compactMap({ $0 as? UILongPressGestureRecognizer}).first {
            longPressRecognizer.minimumPressDuration = 0.5
        }
        
        return interaction
    }()
    
    open override var dragInteractionEnabled: Bool {
        get {
            return dragInteraction.isEnabled
        }
        set {
            dragInteraction.isEnabled = newValue
        }
    }
}

public protocol SDTreeTableViewDataSource: UITableViewDataSource {
    
    func tableView(_ tableView: SDTreeTableView, numberOfRowsAtTreeIndex treeIndex: IndexPath) -> Int
    
}

public protocol SDTreeTableViewDragDelegate: UITableViewDelegate {
    
    func tableView(_ tableView: SDTreeTableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem]
}

public protocol SDTreeTableViewDropDelegate: UITableViewDelegate {
    
    func tableView(_ tableView: SDTreeTableView, insertionInset: Int) -> CGFloat
    
    func tableView(_ tableView: SDTreeTableView, canMoveNodeAt source: IndexPath, to destination: IndexPath) -> Bool
    
    func tableView(_ tableView: SDTreeTableView, moveNodeAt source: IndexPath, to destination: IndexPath)
    
    func tableView(_ tableView: SDTreeTableView, dropSessionDidEnd session: UIDropSession)
}

extension SDTreeTableViewDropDelegate {
    
    public func tableView(_ tableView: SDTreeTableView, insertionInset: Int) -> CGFloat {
        return 0
    }
    
    public func tableView(_ tableView: SDTreeTableView, canMoveNodeAt source: IndexPath, to destination: IndexPath) -> Bool {
        return true
    }
    
    public func tableView(_ tableView: SDTreeTableView, moveNodeAt source: IndexPath, to destination: IndexPath) {
        
    }
    
    public func tableView(_ tableView: SDTreeTableView, dropSessionDidEnd session: UIDropSession) {
        
    }
}

extension SDTreeTableView {
    
    private func numberOfRows(_ prefix: IndexPath = []) -> Int {
        
        guard let dataSource = self.dataSource as? SDTreeTableViewDataSource else { return 0 }
        
        if prefix.isEmpty {
            return (0..<dataSource.tableView(self, numberOfRowsAtTreeIndex: [])).reduce(0) { $0 + self.numberOfRows([$1]) }
        }
        
        if expanded.contains(prefix) {
            return (0..<dataSource.tableView(self, numberOfRowsAtTreeIndex: prefix)).reduce(1) { $0 + self.numberOfRows(prefix + [$1]) }
        }
        
        return 1
    }
    
    private func treeIndex(_ row: Int, _ prefix: IndexPath = []) -> IndexPath? {
        
        guard let dataSource = self.dataSource as? SDTreeTableViewDataSource else { return nil }
        
        var startIndex = 0
        
        for i in 0..<dataSource.tableView(self, numberOfRowsAtTreeIndex: prefix) {
            
            let endIndex = startIndex + self.numberOfRows(prefix + [i])
            
            if startIndex == row {
                return prefix + [i]
            }
            
            if startIndex..<endIndex ~= row {
                return self.treeIndex(row - startIndex - 1, prefix + [i])
            }
            
            startIndex = endIndex
        }
        
        return nil
    }
    
    open override func reloadData() {
        self.expanded.formIntersection((0..<self.numberOfRows()).compactMap { self.treeIndex($0) })
        super.reloadData()
    }
    
    open override var numberOfSections: Int {
        return 1
    }
    
    open override func numberOfRows(inSection section: Int) -> Int {
        return self.numberOfRows()
    }
    
    open func treeIndex(for indexPath: IndexPath) -> IndexPath? {
        return self.treeIndex(indexPath.row)
    }
    
    open func isExpanded(_ indexPath: IndexPath) -> Bool {
        guard let treeIndex = self.treeIndex(indexPath.row) else { return false }
        return self.expanded.contains(treeIndex)
    }
    
    open func children(_ indexPath: IndexPath) -> [IndexPath] {
        guard let treeIndex = self.treeIndex(indexPath.row) else { return [] }
        return (0..<self.numberOfRows(treeIndex)).dropFirst().map { IndexPath(row: indexPath.row + $0, section: 0) }
    }
    
    open func insertNode(at node: IndexPath) {
        
        func check(_ lhs: IndexPath, _ rhs: IndexPath) -> Bool {
            return lhs.count <= rhs.count && rhs.starts(with: lhs.dropLast()) && lhs <= rhs
        }
        func replacing(_ i: IndexPath, _ position: Int, _ index: Int) -> IndexPath {
            return i.prefix(position) + [index] + i.dropFirst(position + 1)
        }
        
        self.expanded = Set(self.expanded.map { check(node, $0) ? replacing($0, node.count - 1, $0[node.count - 1] + 1) : $0 })
    }
    
    open func deleteNode(at node: IndexPath) {
        
        func check(_ lhs: IndexPath, _ rhs: IndexPath) -> Bool {
            return lhs.count <= rhs.count && rhs.starts(with: lhs.dropLast()) && lhs < rhs
        }
        func replacing(_ i: IndexPath, _ position: Int, _ index: Int) -> IndexPath {
            return i.prefix(position) + [index] + i.dropFirst(position + 1)
        }
        
        self.expanded = self.expanded.filter { !$0.starts(with: node) }
        self.expanded = Set(self.expanded.map { check(node, $0) ? replacing($0, node.count - 1, $0[node.count - 1] - 1) : $0 })
    }
    
    open func expandRow(at indexPath: IndexPath, with animation: UITableView.RowAnimation) {
        
        guard let treeIndex = self.treeIndex(indexPath.row) else { return }
        
        self.expanded.insert(treeIndex)
        
        let rows = (0..<self.numberOfRows()).compactMap { row in self.treeIndex(row).map { (row, $0) } }.compactMap { $1 != treeIndex && $1.starts(with: treeIndex) ? IndexPath(row: $0, section: 0) : nil }
        
        self.insertRows(at: rows, with: animation)
    }
    
    open func collapseRow(at indexPath: IndexPath, with animation: UITableView.RowAnimation) {
        
        guard let treeIndex = self.treeIndex(indexPath.row) else { return }
        
        let rows = (0..<self.numberOfRows()).compactMap { row in self.treeIndex(row).map { (row, $0) } }.compactMap { $1 != treeIndex && $1.starts(with: treeIndex) ? IndexPath(row: $0, section: 0) : nil }
        
        self.expanded.remove(treeIndex)
        
        self.deleteRows(at: rows, with: animation)
    }
}

extension SDTreeTableView: UIDragInteractionDelegate, UIDropInteractionDelegate {
    
    private func insertionInset(before destinationIndexPath: IndexPath) -> CGFloat {
        
        guard let dropDelegate = self.delegate as? SDTreeTableViewDropDelegate else { return 0 }
        guard let treeIndex = self.treeIndex(for: destinationIndexPath) else { return 0 }
        
        return dropDelegate.tableView(self, insertionInset: treeIndex.count - 1)
    }
    
    private func insertionInset(after destinationIndexPath: IndexPath, sourceIndexPath: IndexPath, _ outsideBound: Bool) -> CGFloat {
        
        guard let dataSource = self.dataSource as? SDTreeTableViewDataSource else { return 0 }
        guard let dropDelegate = self.delegate as? SDTreeTableViewDropDelegate else { return 0 }
        guard let sourceTreeIndex = self.treeIndex(for: sourceIndexPath) else { return 0 }
        guard let destinationTreeIndex = self.treeIndex(for: destinationIndexPath) else { return 0 }
        
        let children = self.children(sourceIndexPath)
        guard !children.contains(destinationIndexPath) else { return 0 }
        
        let count = dataSource.tableView(self, numberOfRowsAtTreeIndex: destinationTreeIndex)
        
        if dropDelegate.tableView(self, canMoveNodeAt: sourceTreeIndex, to: destinationTreeIndex + [count]) {
            return dropDelegate.tableView(self, insertionInset: destinationTreeIndex.count)
        }
        
        if outsideBound && self.numberOfRows() == destinationIndexPath.row + 1, let position = destinationTreeIndex.first, dropDelegate.tableView(self, canMoveNodeAt: sourceTreeIndex, to: [position + 1]) {
            return dropDelegate.tableView(self, insertionInset: 0)
        }
        
        return dropDelegate.tableView(self, insertionInset: destinationTreeIndex.count - 1)
    }
    
    private func canMoveNode(at sourceIndexPath: IndexPath, before destinationIndexPath: IndexPath) -> Bool {
        
        guard let dropDelegate = self.delegate as? SDTreeTableViewDropDelegate else { return false }
        guard let sourceTreeIndex = self.treeIndex(for: sourceIndexPath) else { return false }
        guard let destinationTreeIndex = self.treeIndex(for: destinationIndexPath) else { return false }
        
        guard !self.children(sourceIndexPath).contains(destinationIndexPath) else { return false }
        
        let _sourceIndexPath = self.children(sourceIndexPath).last ?? sourceIndexPath
        
        guard _sourceIndexPath.row + 1 != destinationIndexPath.row || sourceTreeIndex.count != destinationTreeIndex.count else { return false }
        
        return sourceTreeIndex != destinationTreeIndex && dropDelegate.tableView(self, canMoveNodeAt: sourceTreeIndex, to: destinationTreeIndex)
    }
    
    private func canMoveNode(at sourceIndexPath: IndexPath, after destinationIndexPath: IndexPath, _ outsideBound: Bool) -> Bool {
        
        guard let dropDelegate = self.delegate as? SDTreeTableViewDropDelegate else { return false }
        guard let sourceTreeIndex = self.treeIndex(for: sourceIndexPath) else { return false }
        guard let destinationTreeIndex = self.treeIndex(for: destinationIndexPath) else { return false }
        
        guard !self.children(sourceIndexPath).contains(destinationIndexPath) else { return false }
        
        if dropDelegate.tableView(self, canMoveNodeAt: sourceTreeIndex, to: destinationTreeIndex + [0]) {
            
            return sourceTreeIndex != destinationTreeIndex + [0]
        }
        
        if outsideBound && self.numberOfRows() == destinationIndexPath.row + 1, let position = destinationTreeIndex.first, dropDelegate.tableView(self, canMoveNodeAt: sourceTreeIndex, to: [position + 1]) {
            
            return dropDelegate.tableView(self, canMoveNodeAt: sourceTreeIndex, to: [position + 1])
        }
        
        guard sourceIndexPath.row != destinationIndexPath.row && sourceIndexPath.row != destinationIndexPath.row + 1 else { return false }
        guard self.children(destinationIndexPath).isEmpty else { return false }
        
        if let position = destinationTreeIndex.last {
            
            let _destinationTreeIndex: IndexPath = destinationTreeIndex.dropLast() + [position + 1]
            
            return dropDelegate.tableView(self, canMoveNodeAt: sourceTreeIndex, to: _destinationTreeIndex)
        }
        
        return false
    }
    
    private func moveNode(at sourceIndexPath: IndexPath, before destinationIndexPath: IndexPath) {
        
        guard let dropDelegate = self.delegate as? SDTreeTableViewDropDelegate else { return }
        guard let sourceTreeIndex = self.treeIndex(for: sourceIndexPath) else { return }
        guard let destinationTreeIndex = self.treeIndex(for: destinationIndexPath) else { return }
        
        let children = self.children(sourceIndexPath)
        
        dropDelegate.tableView(self, moveNodeAt: sourceTreeIndex, to: destinationTreeIndex)
        
        self._moveNode(from: sourceTreeIndex, to: destinationTreeIndex)
        self._moveRows(from: [sourceIndexPath] + children, to: destinationIndexPath)
    }
    
    private func moveNode(at sourceIndexPath: IndexPath, after destinationIndexPath: IndexPath, _ outsideBound: Bool) {
        
        guard let dropDelegate = self.delegate as? SDTreeTableViewDropDelegate else { return }
        guard let sourceTreeIndex = self.treeIndex(for: sourceIndexPath) else { return }
        guard let destinationTreeIndex = self.treeIndex(for: destinationIndexPath) else { return }
        
        let children = self.children(sourceIndexPath)
        
        if dropDelegate.tableView(self, canMoveNodeAt: sourceTreeIndex, to: destinationTreeIndex + [0]) {
            
            dropDelegate.tableView(self, moveNodeAt: sourceTreeIndex, to: destinationTreeIndex + [0])
            
            if self.isExpanded(destinationIndexPath) {
                
                self._moveNode(from: sourceTreeIndex, to: destinationTreeIndex + [0])
                self._moveRows(from: [sourceIndexPath] + children, to: IndexPath(row: destinationIndexPath.row + 1, section: 0))
                
            } else {
                
                self.deleteNode(at: sourceTreeIndex)
                
                self.performBatchUpdates({
                    
                    self.deleteRows(at: [sourceIndexPath] + children, with: .automatic)
                    
                }, completion: { _ in
                    
                    if sourceIndexPath < destinationIndexPath {
                        
                        let rows = Swift.min(self.numberOfRows() - 1, destinationIndexPath.row - children.count - 1)
                        self.reloadRows(at: (0...rows).map { IndexPath(row: $0, section: 0) }, with: .none)
                        
                    } else if sourceIndexPath.row != 0 {
                        
                        let rows = Swift.min(self.numberOfRows(), sourceIndexPath.row)
                        self.reloadRows(at: (0..<rows).map { IndexPath(row: $0, section: 0) }, with: .none)
                    }
                })
            }
            
            return
        }
        
        if outsideBound && self.numberOfRows() == destinationIndexPath.row + 1, let position = destinationTreeIndex.first, dropDelegate.tableView(self, canMoveNodeAt: sourceTreeIndex, to: [position + 1]) {
            
            dropDelegate.tableView(self, moveNodeAt: sourceTreeIndex, to: [position + 1])
            
            self._moveNode(from: sourceTreeIndex, to: [position + 1])
            self._moveRows(from: [sourceIndexPath] + children, to: IndexPath(row: destinationIndexPath.row + 1, section: 0))
        }
        
        if let position = destinationTreeIndex.last {
            
            dropDelegate.tableView(self, moveNodeAt: sourceTreeIndex, to: destinationTreeIndex.dropLast() + [position + 1])
            
            self._moveNode(from: sourceTreeIndex, to: destinationTreeIndex.dropLast() + [position + 1])
            self._moveRows(from: [sourceIndexPath] + children, to: IndexPath(row: destinationIndexPath.row + 1, section: 0))
        }
    }
    
    private func _moveNode(from source: IndexPath, to destination: IndexPath) {
        
        func check(_ lhs: IndexPath, _ rhs: IndexPath) -> Bool {
            return lhs.count <= rhs.count && rhs.starts(with: lhs.dropLast()) && lhs <= rhs
        }
        func replacing(_ i: IndexPath, _ position: Int, _ index: Int) -> IndexPath {
            return i.prefix(position) + [index] + i.dropFirst(position + 1)
        }
        
        let _expanded = self.expanded.filter { $0.starts(with: source) }
        self.expanded.subtract(_expanded)
        if source < destination {
            self.expanded = Set(self.expanded.map { check(destination, $0) ? replacing($0, destination.count - 1, $0[destination.count - 1] + 1) : $0 })
            self.expanded.formUnion(_expanded.map { destination + $0.dropFirst(source.count) })
            self.expanded = Set(self.expanded.map { check(source, $0) ? replacing($0, source.count - 1, $0[source.count - 1] - 1) : $0 })
        } else {
            self.expanded = Set(self.expanded.map { check(source, $0) ? replacing($0, source.count - 1, $0[source.count - 1] - 1) : $0 })
            self.expanded = Set(self.expanded.map { check(destination, $0) ? replacing($0, destination.count - 1, $0[destination.count - 1] + 1) : $0 })
            self.expanded.formUnion(_expanded.map { destination + $0.dropFirst(source.count) })
        }
    }
    
    private func _moveRows(from indexPaths: [IndexPath], to newIndexPath: IndexPath) {
        
        guard let first = indexPaths.first else { return }
        
        self.performBatchUpdates({
            
            if first < newIndexPath {
                
                for (i, child) in indexPaths.reversed().enumerated() {
                    self.moveRow(at: child, to: IndexPath(row: newIndexPath.row - i - 1, section: 0))
                }
                
            } else {
                
                for (i, child) in indexPaths.enumerated() {
                    self.moveRow(at: child, to: IndexPath(row: newIndexPath.row + i, section: 0))
                }
            }
            
        }, completion: { _ in
            
            let maxIndexPath = indexPaths.max().map { Swift.max($0, newIndexPath) } ?? newIndexPath
            let rows = Swift.min(self.numberOfRows() - 1, maxIndexPath.row)
            
            self.reloadRows(at: (0...rows).map { IndexPath(row: $0, section: 0) }, with: .none)
        })
    }
    
    public func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        
        let location = session.location(in: self)
        
        guard let indexPath = self.indexPathForRow(at: location) else { return [] }
        
        session.localContext = (self, indexPath)
        
        guard let dragDelegate = self.delegate as? SDTreeTableViewDragDelegate else { return [] }
        return dragDelegate.tableView(self, itemsForBeginning: session, at: indexPath)
    }
    
    public func dragInteraction(_ interaction: UIDragInteraction, previewForLifting item: UIDragItem, session: UIDragSession) -> UITargetedDragPreview? {
        
        guard let (tableView, indexPath) = session.localContext as? (SDTreeTableView, IndexPath), self === tableView else { return nil }
        
        guard let cell = self.cellForRow(at: indexPath) else { return nil }
        
        return UITargetedDragPreview(view: cell)
    }
    
    public func dragInteraction(_ interaction: UIDragInteraction, sessionWillBegin session: UIDragSession) {
        
        guard let (tableView, indexPath) = session.localContext as? (SDTreeTableView, IndexPath), self === tableView else { return }
        
        guard let cell = self.cellForRow(at: indexPath) else { return }
        
        cell.alpha = 0.25
    }
    
    public func dragInteraction(_ interaction: UIDragInteraction, session: UIDragSession, willEndWith operation: UIDropOperation) {
        
        dropInsertionView.isHidden = true
        
        guard let (tableView, indexPath) = session.localContext as? (SDTreeTableView, IndexPath), self === tableView else { return }
        
        guard let cell = self.cellForRow(at: indexPath) else { return }
        
        cell.alpha = 1
    }
    
    public func dragInteraction(_ interaction: UIDragInteraction, sessionIsRestrictedToDraggingApplication session: UIDragSession) -> Bool {
        
        return true
    }
    
    public func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        
        guard self.delegate is SDTreeTableViewDropDelegate else { return false }
        guard let (tableView, _) = session.localDragSession?.localContext as? (SDTreeTableView, IndexPath) else { return false }
        
        return self === tableView
    }
    
    public func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        
        var showInsertion = false
        defer { dropInsertionView.isHidden = !showInsertion }
        
        guard let (tableView, sourceIndexPath) = session.localDragSession?.localContext as? (SDTreeTableView, IndexPath), self === tableView else { return UIDropProposal(operation: .forbidden) }
        
        let location = session.location(in: self)
        
        guard let destinationIndexPath = self.indexPathForRow(at: location) ?? self.indexPathsForVisibleRows?.min(by: { (location - self.rectForRow(at: $0).center).magnitude }) else { return UIDropProposal(operation: .cancel) }
        
        let destinationBound = self.rectForRow(at: destinationIndexPath)
        guard let cell = self.cellForRow(at: destinationIndexPath) else { return UIDropProposal(operation: .cancel) }
        
        if location.y < destinationBound.midY {
            
            guard self.canMoveNode(at: sourceIndexPath, before: destinationIndexPath) else { return UIDropProposal(operation: .cancel) }
            
            let inset = self.insertionInset(before: destinationIndexPath)
            
            showInsertion = true
            self.bringSubviewToFront(dropInsertionView)
            
            dropInsertionViewConstraints = [
                NSLayoutConstraint(item: dropInsertionView, attribute: .leading, relatedBy: .equal, toItem: cell, attribute: .leading, multiplier: 1, constant: inset),
                NSLayoutConstraint(item: dropInsertionView, attribute: .trailing, relatedBy: .equal, toItem: cell, attribute: .trailing, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: dropInsertionView, attribute: .top, relatedBy: .equal, toItem: cell, attribute: .top, multiplier: 1, constant: -1.25),
                NSLayoutConstraint(item: dropInsertionView, attribute: .bottom, relatedBy: .equal, toItem: cell, attribute: .top, multiplier: 1, constant: 1.25),
            ]
            
            return UIDropProposal(operation: .move)
            
        } else {
            
            guard self.canMoveNode(at: sourceIndexPath, after: destinationIndexPath, location.y > destinationBound.maxY) else { return UIDropProposal(operation: .cancel) }
            
            let inset = self.insertionInset(after: destinationIndexPath, sourceIndexPath: sourceIndexPath, location.y > destinationBound.maxY)
            
            showInsertion = true
            self.bringSubviewToFront(dropInsertionView)
            
            dropInsertionViewConstraints = [
                NSLayoutConstraint(item: dropInsertionView, attribute: .leading, relatedBy: .equal, toItem: cell, attribute: .leading, multiplier: 1, constant: inset),
                NSLayoutConstraint(item: dropInsertionView, attribute: .trailing, relatedBy: .equal, toItem: cell, attribute: .trailing, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: dropInsertionView, attribute: .top, relatedBy: .equal, toItem: cell, attribute: .bottom, multiplier: 1, constant: -1.25),
                NSLayoutConstraint(item: dropInsertionView, attribute: .bottom, relatedBy: .equal, toItem: cell, attribute: .bottom, multiplier: 1, constant: 1.25),
            ]
            
            return UIDropProposal(operation: .move)
        }
    }
    
    public func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        
        dropInsertionView.isHidden = true
        
        guard let (tableView, sourceIndexPath) = session.localDragSession?.localContext as? (SDTreeTableView, IndexPath), self === tableView else { return }
        
        let location = session.location(in: self)
        
        guard let destinationIndexPath = self.indexPathForRow(at: location) ?? self.indexPathsForVisibleRows?.min(by: { (location - self.rectForRow(at: $0).center).magnitude }) else { return }
        
        let destinationBound = self.rectForRow(at: destinationIndexPath)
        
        if location.y < destinationBound.midY {
            
            self.moveNode(at: sourceIndexPath, before: destinationIndexPath)
            
        } else {
            
            self.moveNode(at: sourceIndexPath, after: destinationIndexPath, location.y > destinationBound.maxY)
        }
    }
    
    public func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnd session: UIDropSession) {
        
        guard let dropDelegate = self.delegate as? SDTreeTableViewDropDelegate else { return }
        
        dropDelegate.tableView(self, dropSessionDidEnd: session)
    }
}
