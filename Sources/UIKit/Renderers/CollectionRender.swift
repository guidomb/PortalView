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
        let collectionViewLayout = createFlowLayout(itemsWidth: properties.itemsWidth,
                                      itemsHeight: properties.itemsHeight,
                                      minimumInteritemSpacing: properties.minimumInteritemSpacing,
                                      minimumLineSpacing: properties.minimumLineSpacing,
                                      scrollDirection: properties.scrollDirection,
                                      sectionInset: properties.sectionInset)
        let collectionView = PortalCollectionView(items: properties.items, layoutEngine: layoutEngine, layout: collectionViewLayout)
        
        collectionView.isDebugModeEnabled = isDebugModeEnabled
        collectionView.isSnapToCellEnabled = properties.isSnapToCellEnabled
        collectionView.showsHorizontalScrollIndicator = properties.showsHorizontalScrollIndicator
        collectionView.showsVerticalScrollIndicator = properties.showsVerticalScrollIndicator
        
        collectionView.apply(style: style.base)
        layoutEngine.apply(layout: layout, to: collectionView)
        
        return Render(view: collectionView, mailbox: collectionView.mailbox)
    }
    
    func createFlowLayout(itemsWidth: UInt,
                          itemsHeight: UInt,
                          minimumInteritemSpacing: UInt,
                          minimumLineSpacing: UInt,
                          scrollDirection: CollectionScrollDirection,
                          sectionInset: SectionInset) -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: CGFloat(itemsWidth), height: CGFloat(itemsHeight))
        layout.minimumInteritemSpacing = CGFloat(minimumInteritemSpacing)
        layout.minimumLineSpacing = CGFloat(minimumLineSpacing)
        layout.sectionInset = UIEdgeInsets(top: CGFloat(sectionInset.top), left: CGFloat(sectionInset.left), bottom: CGFloat(sectionInset.bottom), right: CGFloat(sectionInset.right))
        
        switch scrollDirection {
        case .horizontal:
            layout.scrollDirection = .horizontal
        default:
            layout.scrollDirection = .vertical
        }
        
        return layout
    }
}

