//
//  PortalNavigationController.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 2/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

public final class PortalNavigationController<MessageType, RendererType: Renderer>: UINavigationController
    where RendererType.MessageType == MessageType {
    
    public let mailbox = Mailbox<MessageType>()
    public var isDebugModeEnabled: Bool = false

    fileprivate let layoutEngine: LayoutEngine
    private let statusBarStyle: UIStatusBarStyle
    
    init(layoutEngine: LayoutEngine, statusBarStyle: UIStatusBarStyle = .`default`) {
        self.statusBarStyle = statusBarStyle
        self.layoutEngine = layoutEngine
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    func push(controller: PortalViewController<MessageType, RendererType>,
              with navigationBar: NavigationBar<MessageType>, animated: Bool) {
        pushViewController(controller, animated: animated)
        self.navigationBar.apply(style: navigationBar.style)
        self.render(navigationBar: navigationBar, inside: controller.navigationItem)
        controller.mailbox.forward(to: mailbox)
    }
    
}

fileprivate extension PortalNavigationController {
    
    fileprivate func render(navigationBar: NavigationBar<MessageType>, inside navigationItem: UINavigationItem) {
        if navigationBar.properties.hideBackButtonTitle {
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        let renderer = NavigationBarTitleRenderer(
            navigationBarTitle: navigationBar.properties.title,
            navigationItem: navigationItem,
            navigationBarSize: self.navigationBar.bounds.size
        )
        renderer.render(with: layoutEngine, isDebugModeEnabled: isDebugModeEnabled) |> { $0.forward(to: mailbox) }
    }
    
}
