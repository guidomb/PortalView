//
//  TouchableRenderer.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 4/3/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

internal struct TouchableRenderer<MessageType>: UIKitRenderer {
    
    let child: Component<MessageType>
    let gesture: Gesture<MessageType>
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<MessageType> {
        var result = child.render(with: layoutEngine, isDebugModeEnabled: isDebugModeEnabled)
        
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
            let recognizer = UITapGestureRecognizer(target: dispatcher, action: #selector(MessageDispatcher<MessageType>.dispatch))
            result.view.addGestureRecognizer(recognizer)
            
        }
        return result
    }
    
}
