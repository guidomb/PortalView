//
//  PortalNavigationController.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 2/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

public final class PortalNavigationController<MessageType, RendererType: Renderer>: UINavigationController, UINavigationControllerDelegate
    where RendererType.MessageType == MessageType {
    
    public let mailbox = Mailbox<MessageType>()
    public var isDebugModeEnabled: Bool = false

    fileprivate let layoutEngine: LayoutEngine
    
    private let statusBarStyle: UIStatusBarStyle
    private var pushingViewController = false
    private var currentNavigationBarOnBack: MessageType? = .none
    
    init(layoutEngine: LayoutEngine, statusBarStyle: UIStatusBarStyle = .`default`) {
        self.statusBarStyle = statusBarStyle
        self.layoutEngine = layoutEngine
        super.init(nibName: nil, bundle: nil)
        self.delegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    func push(controller: PortalViewController<MessageType, RendererType>,
              with navigationBar: NavigationBar<MessageType>, animated: Bool) {
        pushingViewController = true
        currentNavigationBarOnBack = navigationBar.properties.onBack
        pushViewController(controller, animated: animated)
        self.navigationBar.apply(style: navigationBar.style)
        self.render(navigationBar: navigationBar, inside: controller.navigationItem)
        controller.mailbox.forward(to: mailbox)
    }
    
    public func navigationController(_ navigationController: UINavigationController,
                                     didShow viewController: UIViewController, animated: Bool) {
        if pushingViewController {
            pushingViewController = false
        } else if !pushingViewController && topViewController != .none {
            // If a controller is not being pushed and the top view controller
            // is not nil then the navigation controller is poping the top view controller.
            // In which case the `onBack` message should be dispatched.
            currentNavigationBarOnBack |> { self.mailbox.dispatch(message: $0) }
        }
    }
    
}

fileprivate extension PortalNavigationController {
    
    fileprivate func render(navigationBar: NavigationBar<MessageType>, inside navigationItem: UINavigationItem) {
        if navigationBar.properties.hideBackButtonTitle {
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        
        if let title = navigationBar.properties.title {
            let renderer = NavigationBarTitleRenderer(
                navigationBarTitle: title,
                navigationItem: navigationItem,
                navigationBarSize: self.navigationBar.bounds.size
            )
            renderer.render(with: layoutEngine, isDebugModeEnabled: isDebugModeEnabled) |> { $0.forward(to: mailbox) }
        }
    }
    
}

