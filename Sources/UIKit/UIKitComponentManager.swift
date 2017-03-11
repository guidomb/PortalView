//
//  UIKitComponentManager.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 2/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

public final class UIKitComponentManager<MessageType>: Presenter, Renderer {
    
    public var isDebugModeEnabled: Bool = false
    
    public let mailbox = Mailbox<MessageType>()
    
    fileprivate let layoutEngine: LayoutEngine
    
    fileprivate var window: WindowManager<MessageType, UIKitComponentRenderer<MessageType>>
    
    public init(window: UIWindow, layoutEngine: LayoutEngine = YogaLayoutEngine()) {
        self.window = WindowManager(window: window)
        self.layoutEngine = layoutEngine
    }
    
    public func present(component: Component<MessageType>, with root: RootComponent<MessageType>) {
        switch root {
            
        case .simple:
            let rootController = controller(forComponent: component)
            rootController.mailbox.forward(to: mailbox)
            window.rootController = .single(rootController)
            
        case .stack(let navigationBar):
            present(component: component, with: navigationBar)
            
        default:
            assertionFailure("Case not implemented")
            
        }
    }
    
    public func render(component: Component<MessageType>) -> Mailbox<MessageType> {
        switch window.rootController {
            
        case .empty:
            let rootController = controller(forComponent: component)
            window.rootController = .single(rootController)
            rootController.mailbox.forward(to: mailbox)
            return rootController.mailbox
            
        case .single(let controller):
            controller.component = component
            controller.render()
            controller.mailbox.forward(to: mailbox)
            return controller.mailbox
            
        case .navigationController(_, let topController):
            topController.component = component
            topController.render()
            topController.mailbox.forward(to: mailbox)
            return topController.mailbox
            
        }
    }
    
}

fileprivate extension UIKitComponentManager {
    
    fileprivate func present(component: Component<MessageType>, with navigationBar: NavigationBar<MessageType>) {
        
        let navigationBarSize: CGSize
        let containedController = controller(forComponent: component)
        
        if case .navigationController(let navigationController, _) = window.rootController {
            navigationController.pushViewController(containedController, animated: true)
            navigationBarSize = navigationController.navigationBar.bounds.size
        } else {
            let navigationController = PortalNavigationController(
                rootViewController: containedController,
                statusBarStyle: navigationBar.style.component.statusBarStyle.asUIStatusBarStyle
            )
            navigationBarSize = navigationController.navigationBar.bounds.size
            window.rootController = .navigationController(navigationController, topController: containedController)
        }
        
        containedController.navigationController?.navigationBar.apply(style: navigationBar.style)
        containedController.mailbox.forward(to: mailbox)
        
        render(navigationBar: navigationBar, of: navigationBarSize, inside: containedController.navigationItem)
    }
    
    fileprivate func render(navigationBar: NavigationBar<MessageType>, of navigationBarSize: CGSize, inside navigationItem: UINavigationItem) {
        
        if navigationBar.properties.hideBackButtonTitle {
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain,target: nil, action: nil)
        }
        
        render(navigationBarTitle: navigationBar.properties.title, of: navigationBarSize, inside: navigationItem)
    }
    
    fileprivate func render(navigationBarTitle: NavigationBarTitle<MessageType>, of navigationBarSize: CGSize, inside navigationItem: UINavigationItem) {
        
        let renderer = NavigationBarTitleRenderer(
            navigationBarTitle: navigationBarTitle,
            navigationItem: navigationItem,
            navigationBarSize: navigationBarSize
        )
        
        renderer.render(with: layoutEngine, isDebugModeEnabled: isDebugModeEnabled) |> { $0.forward(to: mailbox) }
    }
    
    fileprivate func controller(forComponent component: Component<MessageType>) -> PortalViewController<MessageType, UIKitComponentRenderer<MessageType>> {
        
        return PortalViewController(component: component) {
            var renderer = UIKitComponentRenderer<MessageType>(containerView: $0, layoutEngine: self.layoutEngine)
            renderer.isDebugModeEnabled = self.isDebugModeEnabled
            return renderer
        }
    }
    
}

fileprivate struct WindowManager<MessageType, RendererType: Renderer>
    where RendererType.MessageType == MessageType {
    
    fileprivate var rootController: RootController<MessageType, RendererType> {
        set {
            switch newValue {
            case .single(let controller):
                window.rootViewController = controller
            case .navigationController(let navigationController, _):
                window.rootViewController = navigationController
            case .empty:
                window.rootViewController = .none
            }
            _rootController = newValue
        }
        get {
            return _rootController
        }
    }
    
    private let window: UIWindow
    private var _rootController: RootController<MessageType, RendererType>
    
    init(window: UIWindow) {
        self.window = window
        self._rootController = .empty
        self.rootController = .empty
    }
    
}

fileprivate enum RootController<MessageType, RendererType: Renderer>
    where RendererType.MessageType == MessageType {
    
    case empty
    case navigationController(PortalNavigationController, topController: PortalViewController<MessageType, RendererType>)
    case single(PortalViewController<MessageType, RendererType>)
    
}
