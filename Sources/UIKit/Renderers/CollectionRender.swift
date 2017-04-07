//
//  PortalCollectionView.swift
//  PortalView
//
//  Created by Argentino Ducret on 4/4/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

internal struct CollectionRenderer<MessageType>: UIKitRenderer {
    
    let properties: CollectionProperties<MessageType>
    let style: StyleSheet<EmptyStyleSheet>
    let layout: Layout
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<MessageType> {
        let collectionView = PortalCollectionView(items: properties.items, layoutEngine: layoutEngine, layoutValues: properties.layoutValues)
        
        collectionView.isDebugModeEnabled = isDebugModeEnabled
        collectionView.isSnapToCellEnabled = properties.isSnapToCellEnabled
        collectionView.showsHorizontalScrollIndicator = properties.showsHorizontalScrollIndicator
        collectionView.showsVerticalScrollIndicator = properties.showsVerticalScrollIndicator
        
        collectionView.apply(style: style.base)
        layoutEngine.apply(layout: layout, to: collectionView)
        
        return Render(view: collectionView, mailbox: collectionView.mailbox)
    }
    
}
