//
//  ZipList.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 4/6/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Foundation

public struct ZipList<Element>: Collection, CustomDebugStringConvertible {
    
    
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return count
    }
    
    public var count: Int {
        return left.count + right.count + 1
    }
    
    public var centerIndex: Int {
        return left.count
    }
    
    public var debugDescription: String {
        return "ZipList(\n\tleft: \(left)\n\tcenter: \(center)\n\tright: \(right))"
    }
    
    fileprivate let left: [Element]
    fileprivate let center: Element
    fileprivate let right: [Element]
    
    public init(element: Element) {
        self.init(left: [], center: element, right: [])
    }
    
    public init(left: [Element], center: Element, right: [Element]) {
        self.left = left
        self.center = center
        self.right = right
    }
    
    public subscript(index: Int) -> Element {
        precondition(index >= 0 && index < count, "Index of out bounds")
        if index < left.count {
            return left[index]
        } else if index == left.count {
            return center
        } else {
            return right[index - 2]
        }
    }
    
    public func index(after i: Int) -> Int {
        return i + 1
    }
    
    public func shiftLeft() -> ZipList<Element>? {
        guard let newCenter = right.first else { return .none }
        return ZipList(left: left + [center], center: newCenter, right: Array(right.dropFirst()))
    }
    
    public func shiftRight() -> ZipList<Element>? {
        guard let newCenter = left.last else { return .none }
        return ZipList(left: Array(left.dropLast()), center: newCenter, right: [center] + right)
    }
    
}

extension ZipList {
    
    public func map<NewElement>(_ transform: @escaping (Element) -> NewElement) -> ZipList<NewElement> {
        return ZipList<NewElement>(left: left.map(transform), center: transform(center), right: right.map(transform))
    }
    
}
