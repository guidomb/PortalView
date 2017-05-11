//
//  CarouselRenderer.swift
//  PortalView
//
//  Created by Cristian Ames on 4/17/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

internal struct CarouselRenderer<MessageType, CustomComponentRendererType: UIKitCustomComponentRenderer>: UIKitRenderer
    where CustomComponentRendererType.MessageType == MessageType {
    
    typealias CustomComponentRendererFactory = () -> CustomComponentRendererType
    
    let properties: CarouselProperties<MessageType>
    let style: StyleSheet<EmptyStyleSheet>
    let layout: Layout
    let rendererFactory: CustomComponentRendererFactory
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<MessageType> {
        let carouselView = PortalCarouselView(
            items: properties.items,
            layoutEngine: layoutEngine,
            layout: createFlowLayout(),
            rendererFactory: rendererFactory,
            onSelectionChange: properties.onSelectionChange
        )
        
        carouselView.isDebugModeEnabled = isDebugModeEnabled
        carouselView.isSnapToCellEnabled = properties.isSnapToCellEnabled
        carouselView.showsHorizontalScrollIndicator = properties.showsScrollIndicator
        
        carouselView.apply(style: style.base)
        layoutEngine.apply(layout: layout, to: carouselView)
        
        return Render(view: carouselView, mailbox: carouselView.mailbox)
    }
    
    func createFlowLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: CGFloat(properties.itemsWidth), height: CGFloat(properties.itemsHeight))
        layout.minimumInteritemSpacing = CGFloat(properties.minimumInteritemSpacing)
        layout.minimumLineSpacing = CGFloat(properties.minimumLineSpacing)
        layout.sectionInset = UIEdgeInsets(
            top: CGFloat(properties.sectionInset.top),
            left: CGFloat(properties.sectionInset.left),
            bottom: CGFloat(properties.sectionInset.bottom),
            right: CGFloat(properties.sectionInset.right)
        )
        
        layout.scrollDirection = .horizontal
        
        return layout
    }
}
