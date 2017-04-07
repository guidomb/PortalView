//
//  CollectionView.swift
//  PortalView
//
//  Created by Argentino Ducret on 4/4/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Foundation
import UIKit

public struct CollectionProperties<MessageType> {
    
    public var items: [CollectionItemProperties<MessageType>]
    public var layoutValues: CollectionViewLayoutValues
    public var showsVerticalScrollIndicator: Bool
    public var showsHorizontalScrollIndicator: Bool
    public var isSnapToCellEnabled: Bool
    
    fileprivate init(
        items: [CollectionItemProperties<MessageType>] = [],
        showsVerticalScrollIndicator: Bool = false,
        showsHorizontalScrollIndicator: Bool = false,
        isSnapToCellEnabled: Bool = false,
        layoutValues: CollectionViewLayoutValues) {
        self.items = items
        self.showsVerticalScrollIndicator = showsVerticalScrollIndicator
        self.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator
        self.layoutValues = layoutValues
        self.isSnapToCellEnabled = isSnapToCellEnabled
    }
    
    public func map<NewMessageType>(_ transform: @escaping (MessageType) -> NewMessageType) -> CollectionProperties<NewMessageType> {
        return CollectionProperties<NewMessageType>(
            items: self.items.map { $0.map(transform) },
            showsVerticalScrollIndicator: self.showsVerticalScrollIndicator,
            showsHorizontalScrollIndicator: self.showsHorizontalScrollIndicator,
            isSnapToCellEnabled: self.isSnapToCellEnabled,
            layoutValues: self.layoutValues)
    }
    
}

public struct CollectionItemProperties<MessageType> {
    
    public typealias Renderer = () -> Component<MessageType>
    
    public let onTap: MessageType?
    public let renderer: Renderer
    public let identifier: String
    
    fileprivate init(
        onTap: MessageType?,
        identifier: String,
        renderer: @escaping Renderer) {
        self.onTap = onTap
        self.renderer = renderer
        self.identifier = identifier
    }
    
}

extension CollectionItemProperties {
    
    public func map<NewMessageType>(_ transform: @escaping (MessageType) -> NewMessageType) -> CollectionItemProperties<NewMessageType> {
        return CollectionItemProperties<NewMessageType>(
            onTap: self.onTap.map(transform),
            identifier: self.identifier,
            renderer: { self.renderer().map(transform) }
        )
    }
    
}

public func collection<MessageType>(
    properties: CollectionProperties<MessageType>,
    style: StyleSheet<EmptyStyleSheet> = EmptyStyleSheet.default,
    layout: Layout = layout()) -> Component<MessageType> {
    return .collection(properties, style, layout)
}

public func collectionItem<MessageType>(
    onTap: MessageType? = .none,
    identifier: String,
    renderer: @escaping CollectionItemProperties<MessageType>.Renderer) -> CollectionItemProperties<MessageType> {
    return CollectionItemProperties(onTap: onTap, identifier: identifier, renderer: renderer)
}

public func properties<MessageType>(layoutValues: CollectionViewLayoutValues, configure: (inout CollectionProperties<MessageType>) -> ()) -> CollectionProperties<MessageType> {
    var properties = CollectionProperties<MessageType>(layoutValues: layoutValues)
    configure(&properties)
    return properties
}
