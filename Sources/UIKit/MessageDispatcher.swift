//
//  ObjcMessageDispatcher.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 2/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Foundation

internal final class MessageDispatcher<MessageType>: NSObject {
    
    internal let mailbox: Mailbox<MessageType>
    internal let message: MessageType
    
    init(message: MessageType, mailbox: Mailbox<MessageType> = Mailbox()) {
        self.mailbox = mailbox
        self.message = message
    }
    
    @objc
    internal func dispatch() {
        mailbox.dispatch(message: message)
    }
    
}
