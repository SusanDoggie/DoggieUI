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
}

public protocol SDTreeTableViewDataSource: UITableViewDataSource {
    
    func tableView(_ tableView: SDTreeTableView, numberOfRowsAtTreeIndex treeIndex: IndexPath) -> Int
    
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
