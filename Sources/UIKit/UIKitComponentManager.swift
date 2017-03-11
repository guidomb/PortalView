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
    
    public func present(component: Component<MessageType>, with root: RootComponent<MessageType>, modally: Bool) {
        switch (window.rootController, root, modally) {
        
        case (.some(.single(let presenter)), _, true):
            presentModally(component: component, root: root, onTopOf: presenter)
        
        case (.some(.navigationController(let presenter, _)), _, true):
            presentModally(component: component, root: root, onTopOf: presenter)
        
        case (.some(.navigationController(let navigationController, _)), .stack(let navigationBar), false):
            let containedController = controller(for: component)
            navigationController.push(controller: containedController, with: navigationBar, animated: true)
            
        default:
            let rootController = controller(for: component, root: root)
            window.rootController = rootController
            rootController.mailbox.forward(to: mailbox)
        }
    }
    
    public func render(component: Component<MessageType>) -> Mailbox<MessageType> {
        switch window.rootController {
            
        case .some(.single(let controller)):
            controller.component = component
            controller.render()
            controller.mailbox.forward(to: mailbox)
            return controller.mailbox
            
        case .some(.navigationController(_, let topController)):
            topController.component = component
            topController.render()
            topController.mailbox.forward(to: mailbox)
            return topController.mailbox
            
        default:
            let rootController = controller(for: component)
            window.rootController = .single(rootController)
            rootController.mailbox.forward(to: mailbox)
            return rootController.mailbox
            
        }
    }
    
}

fileprivate extension UIKitComponentManager {
    
    fileprivate func presentModally(component: Component<MessageType>, root: RootComponent<MessageType>,
                                    onTopOf presenter: UIViewController) {
        let rootController = controller(for: component, root: root)
        rootController.mailbox.forward(to: mailbox)
        presenter.present(rootController.renderableController, animated: true, completion: nil)
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
            let containedController = controller(for: component)
            navigationController.push(controller: containedController, with: navigationBar, animated: false)
            return .navigationController(navigationController, topController: containedController)
            
        case .tab(let tabBar):
            fatalError("Root component 'tab' not supported")
            return .single(controller(for: component))
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

fileprivate struct WindowManager<MessageType, RendererType: Renderer>
    where RendererType.MessageType == MessageType {
    
    fileprivate var rootController: RootController<MessageType, RendererType>? {
        set {
            window.rootViewController = newValue.map {
                switch $0 {
                case .single(let controller):
                    return controller
                case .navigationController(let navigationController, _):
                    return navigationController
                }
            }
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

fileprivate enum RootController<MessageType, RendererType: Renderer>
    where RendererType.MessageType == MessageType {
    
    case navigationController(PortalNavigationController<MessageType, RendererType>, topController: PortalViewController<MessageType, RendererType>)
    case single(PortalViewController<MessageType, RendererType>)
    
    var renderableController: UIViewController {
        switch self {
        case .navigationController(let navigationController, _):
            return navigationController
        case .single(let controller):
            return controller
        }
    }
    
    var mailbox: Mailbox<MessageType> {
        switch self {
        case .navigationController(let navigationController, _):
            return navigationController.mailbox
        case .single(let controller):
            return controller.mailbox
        }
    }
    
}
