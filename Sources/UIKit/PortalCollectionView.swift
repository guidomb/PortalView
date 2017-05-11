//
//  PortalCollectionView.swift
//  PortalView
//
//  Created by Argentino Ducret on 4/4/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

public class PortalCollectionView<MessageType, CustomComponentRendererType: UIKitCustomComponentRenderer>: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate
    where CustomComponentRendererType.MessageType == MessageType {
    
    public typealias CustomComponentRendererFactory = () -> CustomComponentRendererType
    
    public let mailbox = Mailbox<MessageType>()
    public var isDebugModeEnabled: Bool = false
    
    let layoutEngine: LayoutEngine
    let items: [CollectionItemProperties<MessageType>]
    let rendererFactory: CustomComponentRendererFactory
    
    public init(items: [CollectionItemProperties<MessageType>], layoutEngine: LayoutEngine, layout: UICollectionViewLayout, rendererFactory: @escaping CustomComponentRendererFactory) {
        self.items = items
        self.layoutEngine = layoutEngine
        self.rendererFactory = rendererFactory
        super.init(frame: .zero, collectionViewLayout: layout)
   
        self.dataSource = self
        self.delegate = self
        
        let identifiers = Set(items.map { $0.identifier })
        identifiers.forEach { register(PortalCollectionViewCell<MessageType, CustomComponentRendererType>.self, forCellWithReuseIdentifier: $0) }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = items[indexPath.row]
        if let cell = dequeueReusableCell(with: item.identifier, for: indexPath) {
            cell.component = itemRender(at: indexPath)
            cell.isDebugModeEnabled = isDebugModeEnabled
            cell.render(layoutEngine: layoutEngine, rendererFactory: rendererFactory)
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        item.onTap |> { mailbox.dispatch(message: $0) }
    }
    
}

fileprivate extension PortalCollectionView {

    fileprivate func dequeueReusableCell(with identifier: String, for indexPath: IndexPath) -> PortalCollectionViewCell<MessageType, CustomComponentRendererType>? {
        if let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? PortalCollectionViewCell<MessageType, CustomComponentRendererType> {
            cell.forward(to: mailbox)
            return cell
        } else {
            return .none
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
