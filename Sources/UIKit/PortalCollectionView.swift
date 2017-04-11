//
//  PortalCollectionView.swift
//  PortalView
//
//  Created by Argentino Ducret on 4/4/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

public final class PortalCollectionView<MessageType>: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    public let mailbox = Mailbox<MessageType>()
    public var isDebugModeEnabled: Bool = false
    public var isSnapToCellEnabled: Bool = false
    
    fileprivate let layoutEngine: LayoutEngine
    fileprivate let items: [CollectionItemProperties<MessageType>]
    fileprivate var selected: Int = 0
    fileprivate var lastOffset: CGFloat = 0
    
    public init(items: [CollectionItemProperties<MessageType>], layoutEngine: LayoutEngine, layout: UICollectionViewLayout) {
        self.items = items
        self.layoutEngine = layoutEngine
        super.init(frame: .zero, collectionViewLayout: layout)
   
        self.dataSource = self
        self.delegate = self
        
        let identifiers = Set(items.map { $0.identifier })
        identifiers.forEach { register(PortalCollectionViewCell<MessageType>.self, forCellWithReuseIdentifier: $0) }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = items[indexPath.row]
        let cell = dequeueReusableCell(with: item.identifier, for: indexPath)
        cell.component = itemRender(at: indexPath)
        cell.isDebugModeEnabled = isDebugModeEnabled
        cell.render()
        
        return cell
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        item.onTap |> { mailbox.dispatch(message: $0) }
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

fileprivate extension PortalCollectionView {
    
    fileprivate func scrollToItem(_ position: Int, animated: Bool) {
        DispatchQueue.main.async {
            let indexPath = IndexPath(item: position, section: 0)
            self.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
        }
    }

    fileprivate func dequeueReusableCell(with identifier: String, for indexPath: IndexPath) -> PortalCollectionViewCell<MessageType> {
        if let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? PortalCollectionViewCell<MessageType> {
            cell.layoutEngine = layoutEngine
            return cell
        } else {
            let cell = PortalCollectionViewCell<MessageType>(layoutEngine: layoutEngine)
            cell.mailbox.forward(to: mailbox)
            return cell
        }
    }
    
    fileprivate func itemRender(at indexPath: IndexPath) -> Component<MessageType> {
        // TODO cache the result of calling renderer. Once the diff algorithm is implemented find a way to only
        // replace items that have changed.
        // IGListKit uses some library or algorithm to diff array. Maybe that can be used to make the array diff
        // more efficient.
        //
        // https://github.com/Instagram/IGListKit
        //
        // Check the video of the talk that presents IGListKit to find the array diff algorithm.
        // Also there is Dwifft which seems to be based in the same algorithm:
        //
        // https://github.com/jflinter/Dwifft
        //
        let item = items[indexPath.row]
        return item.renderer()
    }
    
}
