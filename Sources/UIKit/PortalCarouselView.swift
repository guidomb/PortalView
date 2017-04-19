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
    
    fileprivate let onSelectionChange: (ZipListShiftOperation) -> MessageType?
    fileprivate var lastOffset: CGFloat = 0
    fileprivate var selectedIndex: Int = 0
    
    public override init(items: [CollectionItemProperties<MessageType>], customComponentRenderer: CustomComponentRendererType, layoutEngine: LayoutEngine, layout: UICollectionViewLayout) {
        onSelectionChange = { _ in .none }
        super.init(items: items, customComponentRenderer: customComponentRenderer, layoutEngine: layoutEngine, layout: layout)
    }
    
    public init(items: ZipList<CarouselItemProperties<MessageType>>?, customComponentRenderer: CustomComponentRendererType, layoutEngine: LayoutEngine, layout: UICollectionViewLayout, onSelectionChange: @escaping (ZipListShiftOperation) -> MessageType?) {
        if let items = items {
            let transform = { (item: CarouselItemProperties) -> CollectionItemProperties<MessageType> in
                return collectionItem(
                    onTap: item.onTap,
                    identifier: item.identifier,
                    renderer: item.renderer)
            }
            selectedIndex = Int(items.centerIndex)
            self.onSelectionChange = onSelectionChange
            super.init(items: items.map(transform), customComponentRenderer: customComponentRenderer, layoutEngine: layoutEngine, layout: layout)
            scrollToItem(self.selectedIndex, animated: false)
        } else {
            self.onSelectionChange = onSelectionChange
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
        
        let lastPosition = selectedIndex
        if currentOffset > lastOffset {
            if lastPosition < items.count - 1 {
                selectedIndex = lastPosition + 1
                scrollToItem(selectedIndex, animated: true) // Move to the right
                onSelectionChange(.left(count: 1)) |> { mailbox.dispatch(message: $0) }
            }
        } else if currentOffset < lastOffset {
            if lastPosition >= 1 {
                selectedIndex = lastPosition - 1
                scrollToItem(selectedIndex, animated: true) // Move to the left
                onSelectionChange(.right(count: 1)) |> { mailbox.dispatch(message: $0) }
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
    
    fileprivate func shiftDirection(actual: Int, old: Int) -> ZipListShiftOperation? {
        if actual < old {
            return ZipListShiftOperation.left(count: UInt(old - actual))
        } else if actual > old {
            return ZipListShiftOperation.right(count: UInt(actual - old))
        } else {
            return .none
        }
    }
    
}
