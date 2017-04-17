//
//  UIKitRenderer.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 2/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

public protocol UIKitCustomComponentRenderer {
    
    associatedtype MessageType
    
    func handleInitialization(of parentController: UIViewController, forComponent componentIdentifier: String)
    
    func renderComponent(withIdentifier identifier: String, inside view: UIView, dispatcher: (MessageType) -> Void)
    
}

public struct VoidCustomComponentRenderer<MessageType>: UIKitCustomComponentRenderer {
    
    public init() {
        
    }
    
    public func handleInitialization(of parentController: UIViewController, forComponent componentIdentifier: String) {
        
    }
    
    public func renderComponent(withIdentifier identifier: String, inside view: UIView, dispatcher: (MessageType) -> Void) {
        
    }
}

public struct UIKitComponentRenderer<MessageType, CustomComponentRendererType: UIKitCustomComponentRenderer>: Renderer
    where CustomComponentRendererType.MessageType == MessageType {
    
    public var isDebugModeEnabled: Bool = false
    
    internal let layoutEngine: LayoutEngine
    internal let customComponentRenderer: CustomComponentRendererType
    
    private let containerView: UIView
    
    public init(
        containerView: UIView,
        customComponentRenderer: CustomComponentRendererType,
        layoutEngine: LayoutEngine = YogaLayoutEngine()) {
        self.containerView = containerView
        self.customComponentRenderer = customComponentRenderer
        self.layoutEngine = layoutEngine
    }
    
    public func render(component: Component<MessageType>) -> Mailbox<MessageType> {
        containerView.subviews.forEach { $0.removeFromSuperview() }
        let renderer = ComponentRenderer(component: component, customComponentRenderer: customComponentRenderer)
        let renderResult = renderer.render(with: layoutEngine, isDebugModeEnabled: isDebugModeEnabled)
        renderResult.view.managedByPortal = true
        layoutEngine.layout(view: renderResult.view, inside: containerView)
        renderResult.afterLayout?()
        
        if isDebugModeEnabled {
            renderResult.view.safeTraverse { $0.addDebugFrame() }
        }
        
        return renderResult.mailbox ?? Mailbox<MessageType>()
    }
    
}

internal typealias AfterLayoutTask = () -> ()

internal struct Render<MessageType> {
    
    let view: UIView
    let mailbox: Mailbox<MessageType>?
    let afterLayout: AfterLayoutTask?
    
    init(view: UIView, mailbox: Mailbox<MessageType>? = .none, executeAfterLayout afterLayout: AfterLayoutTask? = .none) {
        self.view = view
        self.afterLayout = afterLayout
        self.mailbox = mailbox
    }
    
}

internal protocol UIKitRenderer {
    
    associatedtype MessageType
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<MessageType>
    
}

extension UIView {
    
    internal func apply(style: BaseStyleSheet) {
        style.backgroundColor   |> { self.backgroundColor = $0.asUIColor }
        style.cornerRadius      |> { self.layer.cornerRadius = CGFloat($0) }
        style.borderColor       |> { self.layer.borderColor = $0.asUIColor.cgColor }
        style.borderWidth       |> { self.layer.borderWidth = CGFloat($0) }
        style.alpha             |> { self.alpha = CGFloat($0) }
        
    }
    
}

