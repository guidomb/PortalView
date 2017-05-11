//
//  TouchableRenderer.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 4/3/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

internal struct TouchableRenderer<MessageType, CustomComponentRendererType: UIKitCustomComponentRenderer>: UIKitRenderer
    where CustomComponentRendererType.MessageType == MessageType {
    
    typealias CustomComponentRendererFactory = () -> CustomComponentRendererType
    
    let child: Component<MessageType>
    let gesture: Gesture<MessageType>
    let rendererFactory: CustomComponentRendererFactory
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<MessageType> {
        let renderer = ComponentRenderer(component: child, rendererFactory: rendererFactory)
        var result = renderer.render(with: layoutEngine, isDebugModeEnabled: isDebugModeEnabled)
        
        result.view.isUserInteractionEnabled = true
        
        switch gesture {
            
        case .tap(let message):
            let dispatcher: MessageDispatcher<MessageType>
            if let mailbox = result.mailbox {
              dispatcher = MessageDispatcher(mailbox: mailbox, message: message)
            } else {
                dispatcher = MessageDispatcher(message: message)
                result = Render(view: result.view, mailbox: dispatcher.mailbox, executeAfterLayout: result.afterLayout)
            }
            result.view.register(dispatcher: dispatcher)
            let recognizer = UITapGestureRecognizer(target: dispatcher, action: dispatcher.selector)
            result.view.addGestureRecognizer(recognizer)
            
        }
        return result
    }
    
}
