//
//  PortalCollectionViewCell.swift
//  PortalView
//
//  Created by Argentino Ducret on 4/4/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

public final class PortalCollectionViewCell<MessageType, CustomComponentRendererType: UIKitCustomComponentRenderer>: UICollectionViewCell
    where CustomComponentRendererType.MessageType == MessageType {
    
    public var component: Component<MessageType>? = .none
    public var isDebugModeEnabled: Bool {
        set {
            self.renderer?.isDebugModeEnabled = newValue
        }
        get {
            return self.renderer?.isDebugModeEnabled ?? false
        }
    }
    
    fileprivate var renderer: UIKitComponentRenderer<MessageType, CustomComponentRendererType>? = .none
    
    private let mailbox = Mailbox<MessageType>()
    private var mailboxForwarded = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func render(customComponentRenderer: CustomComponentRendererType, layoutEngine: LayoutEngine) {
        // TODO check if we need to do something about after layout hooks
        // TODO improve rendering performance by avoiding allocations.
        // Renderers should be able to reuse view objects instead of having
        // to allocate new ones if possible.
        if renderer == nil {
            createRenderer(customComponentRenderer: customComponentRenderer, layoutEngine: layoutEngine)
        }
        
        if let component = self.component, let componentMailbox = renderer?.render(component: component) {
            componentMailbox.forward(to: mailbox)
        }
    }
    
    public func forward(to mailbox: Mailbox<MessageType>) {
        guard !mailboxForwarded else { return }
        
        self.mailbox.forward(to: mailbox)
        mailboxForwarded = true
    }
    
}

fileprivate extension PortalCollectionViewCell {
    
    fileprivate func createRenderer(customComponentRenderer: CustomComponentRendererType, layoutEngine: LayoutEngine) {
        renderer = UIKitComponentRenderer(
            containerView: contentView,
            customComponentRenderer: customComponentRenderer,
            layoutEngine: layoutEngine
        )
    }
    
}
