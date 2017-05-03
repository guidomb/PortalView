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
    
    public func present(component: Component<MessageType>, with root: RootComponent<MessageType>, modally: Bool, orientation: SupportedOrientations) {
        if modally {
            if window.currentModal != nil {
                dismissCurrentModal {
                    self.presentModally(component: component, root: root, orientation: orientation)
                }
            } else {
                presentModally(component: component, root: root, orientation: orientation)
            }
            return
        }
        
        switch (window.visibleController, root) {
        case (.some(.navigationController(let navigationController)), .stack(let navigationBar)):
            let containedController = controller(for: component, orientation: orientation)
            navigationController.push(controller: containedController, with: navigationBar, animated: true)
            
        default:
            let rootController = controller(for: component, root: root, orientation: orientation)
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
            let rootController = controller(for: component, orientation: .all)
            window.rootController = .single(rootController)
            rootController.mailbox.forward(to: mailbox)
            return rootController.mailbox
        }
    }
    
    public func render(component: Component<MessageType>, with root: RootComponent<MessageType>, orientation: SupportedOrientations) {
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
            let rootController = controller(for: component, root: root, orientation: orientation)
            window.rootController = rootController
            rootController.mailbox.forward(to: mailbox)
        }
        
        // TODO Handle case where window.visibleController.orientation != orientation
    }
    
    public func dismissCurrentModal(completion: @escaping () -> Void) {
        window.currentModal?.renderableController.dismiss(animated: true) {
            self.window.currentModal = .none
            completion()
        }
    }
    
}

fileprivate extension UIKitComponentManager {
    
    fileprivate func presentModally(component: Component<MessageType>, root: RootComponent<MessageType>, orientation: SupportedOrientations) {
        guard let presenter = window.visibleController?.renderableController else { return }
        
        let rootController = controller(for: component, root: root, orientation: orientation)
        rootController.mailbox.forward(to: mailbox)
        presenter.present(rootController.renderableController, animated: true, completion: nil)
        window.currentModal = rootController
    }
    
    fileprivate func controller(for component: Component<MessageType>, root: RootComponent<MessageType>, orientation: SupportedOrientations)
        -> ComponentController<MessageType, CustomComponentRendererType> {
        switch root {
        
        case .simple:
            return .single(controller(for: component, orientation: orientation))
            
        case .stack(let navigationBar):
            let navigationController = PortalNavigationController<MessageType, CustomComponentRendererType>(
                customComponentRenderer: customComponentRenderer,
                layoutEngine: layoutEngine,
                statusBarStyle: navigationBar.style.component.statusBarStyle.asUIStatusBarStyle,
                orientation: orientation
            )
            navigationController.isDebugModeEnabled = isDebugModeEnabled
            let containedController = controller(for: component, orientation: orientation)
            navigationController.push(controller: containedController, with: navigationBar, animated: false)
            return .navigationController(navigationController)
            
        case .tab(_):
            fatalError("Root component 'tab' not supported")
        }
    }
    
    fileprivate func controller(for component: Component<MessageType>, orientation: SupportedOrientations) -> PortalViewController<MessageType, CustomComponentRendererType> {
        
        let controller: PortalViewController<MessageType, CustomComponentRendererType> =  PortalViewController(component: component) {
            var renderer = ComponentRenderer(
                containerView: $0,
                customComponentRenderer: self.customComponentRenderer,
                layoutEngine: self.layoutEngine
            )
            renderer.isDebugModeEnabled = self.isDebugModeEnabled
            return renderer
        }
        controller.orientation = orientation
        
        return controller
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
