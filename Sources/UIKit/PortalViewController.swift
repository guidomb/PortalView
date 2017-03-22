//
//  PortalViewController.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 2/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

public final class PortalViewController<MessageType, RendererType: Renderer>: UIViewController
    where RendererType.MessageType == MessageType {
    
    public typealias RendererFactory = (UIView) -> RendererType
    
    public var component: Component<MessageType>
    public let mailbox = Mailbox<MessageType>()
    
    private let createRenderer: RendererFactory
    
    public init(component: Component<MessageType>, factory createRenderer: @escaping RendererFactory) {
        self.component = component
        self.createRenderer = createRenderer
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        render()
    }
    
    public func render() {
        // For some reason, probably related to Yoga, we need to create
        // a new view when updating a contained controller's view whos
        // parent is a navigation controller because if not the view
        // does not take into account the navigation bar in order
        // to sets its visible size.
        mailbox.unregisterSubscribers()
        self.view = UIView(frame: calculateViewBounds())
        let renderer = createRenderer(view)
        let componentMailbox = renderer.render(component: component)
        componentMailbox.forward(to: mailbox)
    }
    
}

fileprivate extension PortalViewController {
    
    fileprivate var statusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.size.height
    }
    
    
    /// The bounds of the container view used to render the controller's component
    /// needs to be calcuated using this method because if the component is redenred
    /// on the viewDidLoad method for some reason UIKit reports the controller's view bounds
    /// to be equal to the screen's frame. Which does not take into account the status bar
    /// nor the navigation bar if the controllers is embeded inside a navigation controller.
    ///
    /// The funny thing is that if you ask for the controller's view bounds inside viewWillAppear
    /// the bounds are properly set but the component needs to be rendered cannot be rendered in
    /// viewWillAppear because some views, like UITableView have unexpected behavior.
    ///
    /// - Returns: The view bounds that should be used to render the component's view
    fileprivate func calculateViewBounds() -> CGRect {
        var bounds = view.bounds
        bounds.size.height -= statusBarHeight
        bounds.origin.x += statusBarHeight
        
        if let navBarBounds = navigationController?.navigationBar.bounds {
            bounds.size.height -= navBarBounds.size.height
            bounds.origin.x += navBarBounds.size.height
        }
        
        return bounds
    }
    
}
