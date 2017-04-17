//
//  PortalCarouselView.swift
//  PortalView
//
//  Created by Cristian Ames on 4/17/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//
import UIKit

public final class PortalCarouselView<MessageType, CustomComponentRendererType: UIKitCustomComponentRenderer>: PortalCollectionView<MessageType, CustomComponentRendererType>
    where CustomComponentRendererType.MessageType == MessageType {
    
    public var isSnapToCellEnabled: Bool = false
    
    fileprivate let scrolledMessages: [MessageType?]
    fileprivate var lastOffset: CGFloat = 0
    fileprivate var selected: Int = 0 { didSet {
            scrolledMessages[selected] |> { mailbox.dispatch(message: $0) }
        }
    }
    
    public override init(items: [CollectionItemProperties<MessageType>], customComponentRenderer: CustomComponentRendererType, layoutEngine: LayoutEngine, layout: UICollectionViewLayout) {
        scrolledMessages = items.map { _ in .none }
        super.init(items: items, customComponentRenderer: customComponentRenderer, layoutEngine: layoutEngine, layout: layout)
    }
    
    public init(items: ZipList<CarouselItemProperties<MessageType>>?, customComponentRenderer: CustomComponentRendererType, layoutEngine: LayoutEngine, layout: UICollectionViewLayout) {
        if let items = items {
            let transform = { (item: CarouselItemProperties) -> CollectionItemProperties<MessageType> in
                return collectionItem(
                    onTap: item.onTap,
                    identifier: item.identifier,
                    renderer: item.renderer)
            }
            selected = Int(items.centerIndex)
            scrolledMessages = items.map { $0.onScrolled }
            super.init(items: items.map(transform), customComponentRenderer: customComponentRenderer, layoutEngine: layoutEngine, layout: layout)
            scrollToItem(self.selected, animated: false)
        } else {
            scrolledMessages = []
            super.init(items: [], customComponentRenderer: customComponentRenderer, layoutEngine: layoutEngine, layout: layout)
        }
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastOffset = scrollView.contentOffset.x
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint,
                                          targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard isSnapToCellEnabled else { return }
        
        let currentOffset = CGFloat(scrollView.contentOffset.x)
        
        if currentOffset == lastOffset {
            return
        }
        
        let lastPosition = selected
        if currentOffset > lastOffset {
            if lastPosition < items.count - 1 {
                selected = lastPosition + 1 // Move to the right
                scrollToItem(selected, animated: true)
            }
        } else if currentOffset < lastOffset {
            if lastPosition >= 1 {
                selected = lastPosition - 1
                scrollToItem(selected, animated: true) // Move to the left
            }
        }
    }
    
}

fileprivate extension PortalCarouselView {
    
    fileprivate func scrollToItem(_ position: Int, animated: Bool) {
        DispatchQueue.main.async {
            let indexPath = IndexPath(item: position, section: 0)
            self.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
        }
    }
    
}
