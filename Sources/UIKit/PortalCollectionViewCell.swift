//
//  PortalCollectionViewCell.swift
//  PortalView
//
//  Created by Argentino Ducret on 4/4/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

public final class PortalCollectionViewCell<MessageType>: UICollectionViewCell {
    
    public let mailbox = Mailbox<MessageType>()
    public var component: Component<MessageType>? = .none
    public var isDebugModeEnabled: Bool {
        set {
            self.renderer?.isDebugModeEnabled = newValue
        }
        get {
            return self.renderer?.isDebugModeEnabled ?? false
        }
    }
    
    public var layoutEngine: LayoutEngine? = .none {
        didSet {
            if let layoutEngine = layoutEngine {
                self.renderer = UIKitComponentRenderer(containerView: contentView, layoutEngine: layoutEngine)
            }
        }
    }
    
    private var renderer: UIKitComponentRenderer<MessageType>? = .none
    
    public init(layoutEngine: LayoutEngine) {
        super.init(frame: .zero)
        self.renderer = UIKitComponentRenderer(containerView: contentView, layoutEngine: layoutEngine)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func render() {
        // TODO check if we need to do something about after layout hooks
        // TODO improve rendering performance by avoiding allocations.
        // Renderers should be able to reuse view objects instead of having
        // to allocate new ones if possible.
        if let component = self.component, let componentMailbox = renderer?.render(component: component) {
            componentMailbox.forward(to: mailbox)
        }
    }
    
}
