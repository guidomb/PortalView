//
//  UIKitComponentManager.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 2/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

public final class UIKitComponentManager<MessageType, CustomComponentRendererType: UIKitCustomComponentRenderer>: Renderer
    where CustomComponentRendererType.MessageType == MessageType {
    
    public typealias ComponentRenderer = UIKitComponentRenderer<MessageType, CustomComponentRendererType>
    
    public var isDebugModeEnabled: Bool = false
    
    public let mailbox = Mailbox<MessageType>()
    
    public var visibleController: ComponentController<MessageType, CustomComponentRendererType>? {
        return window.visibleController
    }
    
    fileprivate let layoutEngine: LayoutEngine
    fileprivate let customComponentRenderer: CustomComponentRendererType
    fileprivate var window: WindowManager<MessageType, CustomComponentRendererType>
    
    public init(window: UIWindow, customComponentRenderer: CustomComponentRendererType, layoutEngine: LayoutEngine = YogaLayoutEngine()) {
        self.window = WindowManager(window: window)
        self.customComponentRenderer = customComponentRenderer
        self.layoutEngine = layoutEngine
    }
    
    public func present(component: Component<MessageType>, with root: RootComponent<MessageType>, modally: Bool) {
        switch (window.visibleController, root, modally) {
        
        case (.some(.single(let presenter)), _, true):
            presentModally(component: component, root: root, onTopOf: presenter)
        
        case (.some(.navigationController(let presenter)), _, true):
            presentModally(component: component, root: root, onTopOf: presenter)
        
        case (.some(.navigationController(let navigationController)), .stack(let navigationBar), false):
            let containedController = controller(for: component)
            navigationController.push(controller: containedController, with: navigationBar, animated: true)
            
        default:
            let rootController = controller(for: component, root: root)
            window.rootController = rootController
            rootController.mailbox.forward(to: mailbox)
        }
    }
    
    public func render(component: Component<MessageType>) -> Mailbox<MessageType> {
        switch window.visibleController {
            
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
        switch (window.visibleController, root) {
            
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
    
    public func dismissCurrentModal(completion: @escaping () -> Void) {
        window.currentModal?.renderableController.dismiss(animated: true) {
            self.window.currentModal = .none
            completion()
        }
    }
    
}

fileprivate extension UIKitComponentManager {
    
    fileprivate func presentModally(component: Component<MessageType>, root: RootComponent<MessageType>,
                                    onTopOf presenter: UIViewController) {
        if let currentModal = window.currentModal {
            currentModal.renderableController.dismiss(animated: false, completion: .none)
        }
        
        let rootController = controller(for: component, root: root)
        rootController.mailbox.forward(to: mailbox)
        presenter.present(rootController.renderableController, animated: true, completion: nil)
        window.currentModal = rootController
    }
    
    fileprivate func controller(for component: Component<MessageType>, root: RootComponent<MessageType>)
        -> ComponentController<MessageType, CustomComponentRendererType> {
        switch root {
        
        case .simple:
            return .single(controller(for: component))
            
        case .stack(let navigationBar):
            let navigationController = PortalNavigationController<MessageType, CustomComponentRendererType>(
                customComponentRenderer: customComponentRenderer,
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
    
    fileprivate func controller(for component: Component<MessageType>) -> PortalViewController<MessageType, CustomComponentRendererType> {
        
        return PortalViewController(component: component) {
            var renderer = ComponentRenderer(
                containerView: $0,
                customComponentRenderer: self.customComponentRenderer,
                layoutEngine: self.layoutEngine
            )
            renderer.isDebugModeEnabled = self.isDebugModeEnabled
            return renderer
        }
    }
    
}

public enum ComponentController<MessageType, CustomComponentRendererType: UIKitCustomComponentRenderer>
    where CustomComponentRendererType.MessageType == MessageType {
    
    case navigationController(PortalNavigationController<MessageType, CustomComponentRendererType>)
    case single(PortalViewController<MessageType, CustomComponentRendererType>)
    
    public var renderableController: UIViewController {
        switch self {
        case .navigationController(let navigationController):
            return navigationController
        case .single(let controller):
            return controller
        }
    }
    
    public var mailbox: Mailbox<MessageType> {
        switch self {
        case .navigationController(let navigationController):
            return navigationController.mailbox
        case .single(let controller):
            return controller.mailbox
        }
    }
    
}

fileprivate struct WindowManager<MessageType, CustomComponentRendererType: UIKitCustomComponentRenderer>
    where CustomComponentRendererType.MessageType == MessageType {
    
    fileprivate var rootController: ComponentController<MessageType, CustomComponentRendererType>? {
        set {
            window.rootViewController = newValue?.renderableController
            _rootController = newValue
        }
        get {
            return _rootController
        }
    }
    
    fileprivate var visibleController: ComponentController<MessageType, CustomComponentRendererType>? {
        return currentModal ?? rootController
    }
    
    fileprivate var currentModal: ComponentController<MessageType, CustomComponentRendererType>?
    
    private let window: UIWindow
    private var _rootController: ComponentController<MessageType, CustomComponentRendererType>?
    
    init(window: UIWindow) {
        self.window = window
        self._rootController = .none
        self.rootController = .none
        self.currentModal = .none
    }
    
}
