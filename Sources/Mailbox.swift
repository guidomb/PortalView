//
//  Mailbox.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 1/27/17.
//
//

import Foundation

public protocol MailboxProtocol {
    
    associatedtype MessageType
    
    func subscribe(subscriber: @escaping (MessageType) -> ())
    
}

public final class Mailbox<MessageType>: MailboxProtocol {
    
    fileprivate var subscribers: [(MessageType) -> ()] = []
    
    public func subscribe(subscriber: @escaping (MessageType) -> ()) {
        subscribers.append(subscriber)
    }
    
}

extension Mailbox {
    
    internal func dispatch(message: MessageType) {
        subscribers.forEach { $0(message) }
    }
    
    internal func forward(to mailbox: Mailbox<MessageType>) {
        subscribe { mailbox.dispatch(message: $0) }
    }
    
}
