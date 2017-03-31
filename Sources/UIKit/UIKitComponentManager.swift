//
//  UIKitComponentManager.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 2/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

public final class UIKitComponentManager<MessageType>: Renderer {
    
    public var isDebugModeEnabled: Bool = false
    
    public let mailbox = Mailbox<MessageType>()
    
    public var rootController: RootController<MessageType, UIKitComponentRenderer<MessageType>>? {
        return window.rootController
    }
    
    fileprivate let layoutEngine: LayoutEngine
    
    fileprivate var window: WindowManager<MessageType, UIKitComponentRenderer<MessageType>>
    
    public init(window: UIWindow, layoutEngine: LayoutEngine = YogaLayoutEngine()) {
        self.window = WindowManager(window: window)
        self.layoutEngine = layoutEngine
    }
    
    public func present(component: Component<MessageType>, with root: RootComponent<MessageType>, modally: Bool) -> UIViewController {
        switch (window.rootController, root, modally) {
        
        case (.some(.single(let presenter)), _, true):
            return presentModally(component: component, root: root, onTopOf: presenter)
        
        case (.some(.navigationController(let presenter)), _, true):
            return presentModally(component: component, root: root, onTopOf: presenter)
        
        case (.some(.navigationController(let navigationController)), .stack(let navigationBar), false):
            let containedController = controller(for: component)
            navigationController.push(controller: containedController, with: navigationBar, animated: true)
            return navigationController
            
        default:
            let rootController = controller(for: component, root: root)
            window.rootController = rootController
            rootController.mailbox.forward(to: mailbox)
            return rootController.renderableController
        }
    }
    
    public func render(component: Component<MessageType>) -> Mailbox<MessageType> {
        switch window.rootController {
            
        case .some(.single(let controller)):
            controller.component = component
            controller.render()
            return controller.mailbox
            
        case .some(.navigationController(let navigationController)):
            guard let topController = navigationController.topController else {
                // TODO better handle this case
                return Mailbox()
            }
            topController.component = component
            topController.render()
            return topController.mailbox
            
        default:
            let rootController = controller(for: component)
            window.rootController = .single(rootController)
            rootController.mailbox.forward(to: mailbox)
            return rootController.mailbox
            
        }
    }
    
    public func render(component: Component<MessageType>, with root: RootComponent<MessageType>) {
        switch (window.rootController, root) {
            
        case (.some(.single(let controller)), .simple):
            controller.component = component
            controller.render()
            
        case (.some(.navigationController(let navigationController)), .stack(let navigationBar)):
            guard let topController = navigationController.topController else {
                // TODO better handle this case
                return
            }
            topController.component = component
            topController.render()
            navigationController.render(navigationBar: navigationBar, inside: topController.navigationItem)
            
        default:
            let rootController = controller(for: component, root: root)
            window.rootController = rootController
            rootController.mailbox.forward(to: mailbox)
        }
    }
    
}

fileprivate extension UIKitComponentManager {
    
    fileprivate func presentModally(component: Component<MessageType>, root: RootComponent<MessageType>,
                                    onTopOf presenter: UIViewController) -> UIViewController {
        let rootController = controller(for: component, root: root)
        rootController.mailbox.forward(to: mailbox)
        presenter.present(rootController.renderableController, animated: true, completion: nil)
        return rootController.renderableController
    }
    
    fileprivate func controller(for component: Component<MessageType>, root: RootComponent<MessageType>)
        -> RootController<MessageType, UIKitComponentRenderer<MessageType>> {
        switch root {
        
        case .simple:
            return .single(controller(for: component))
            
        case .stack(let navigationBar):
            let navigationController = PortalNavigationController<MessageType, UIKitComponentRenderer<MessageType>>(
                layoutEngine: layoutEngine,
                statusBarStyle: navigationBar.style.component.statusBarStyle.asUIStatusBarStyle
            )
            navigationController.isDebugModeEnabled = isDebugModeEnabled
            let containedController = controller(for: component)
            navigationController.push(controller: containedController, with: navigationBar, animated: false)
            return .navigationController(navigationController)
            
        case .tab(_):
            fatalError("Root component 'tab' not supported")
        }
    }
    
    fileprivate func controller(for component: Component<MessageType>) -> PortalViewController<MessageType, UIKitComponentRenderer<MessageType>> {
        
        return PortalViewController(component: component) {
            var renderer = UIKitComponentRenderer<MessageType>(containerView: $0, layoutEngine: self.layoutEngine)
            renderer.isDebugModeEnabled = self.isDebugModeEnabled
            return renderer
        }
    }
    
}

public enum RootController<MessageType, RendererType: Renderer>
    where RendererType.MessageType == MessageType {
    
    case navigationController(PortalNavigationController<MessageType, RendererType>)
    case single(PortalViewController<MessageType, RendererType>)
    
    var renderableController: UIViewController {
        switch self {
        case .navigationController(let navigationController):
            return navigationController
        case .single(let controller):
            return controller
        }
    }
    
    var mailbox: Mailbox<MessageType> {
        switch self {
        case .navigationController(let navigationController):
            return navigationController.mailbox
        case .single(let controller):
            return controller.mailbox
        }
    }
    
}

fileprivate struct WindowManager<MessageType, RendererType: Renderer>
    where RendererType.MessageType == MessageType {
    
    fileprivate var rootController: RootController<MessageType, RendererType>? {
        set {
            window.rootViewController = newValue?.renderableController
            _rootController = newValue
        }
        get {
            return _rootController
        }
    }
    
    private let window: UIWindow
    private var _rootController: RootController<MessageType, RendererType>?
    
    init(window: UIWindow) {
        self.window = window
        self._rootController = .none
        self.rootController = .none
    }
    
}
