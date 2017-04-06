//
//  SegmentedRenderer.swift
//  PortalView
//
//  Created by Cristian Ames on 4/4/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

internal struct SegmentedRenderer<MessageType>: UIKitRenderer {
    
    let properties: SegmentedProperties<MessageType>
    let style: StyleSheet<SegmentedStyleSheet>
    let layout: Layout
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<MessageType> {
        let segmentedControl = UISegmentedControl(items: [])
        
        properties.segments.enumerated().forEach { index, item in
            item.content |> { content in
                switch content {
                case .image(let image):
                    segmentedControl.insertSegment(with: image.asUIImage, at: index, animated: false)
                case .title(let text):
                    segmentedControl.insertSegment(withTitle: text, at: index, animated: false)
                    
                }
            }
            segmentedControl.setEnabled(item.isEnabled, forSegmentAt: index)
        }
        
        segmentedControl.selectedSegmentIndex = Int(properties.selectedIndex)
        
        segmentedControl.apply(style: style.base)
        segmentedControl.apply(style: style.component)
        layoutEngine.apply(layout: layout, to: segmentedControl)
        
        segmentedControl.unregisterDispatchers()
        segmentedControl.removeTarget(.none, action: .none, for: .valueChanged)
        let mailbox = segmentedControl.bindMessageDispatcher { mailbox in
            _ = segmentedControl.dispatch(
                messages: properties.segments.map { $0.onTap },
                for: .valueChanged, with: mailbox
            )
        }
        
        return Render(view: segmentedControl, mailbox: mailbox)
    }
    
}

extension UISegmentedControl {
    
    fileprivate func dispatch<MessageType>(messages: [MessageType?], for event: UIControlEvents, with mailbox: Mailbox<MessageType> = Mailbox()) -> Mailbox<MessageType> {
        
        let dispatcher = MessageDispatcher(mailbox: mailbox) { sender in
            guard let segmentedControl = sender as? UISegmentedControl else { return .none }
            let index = segmentedControl.selectedSegmentIndex
            return index < messages.count ? messages[index] : .none
        }
        self.register(dispatcher: dispatcher)
        self.addTarget(dispatcher, action: #selector(MessageDispatcher<MessageType>.dispatch), for: event)
        return dispatcher.mailbox
    }
    
}


extension UISegmentedControl {
    
    fileprivate func apply(style: SegmentedStyleSheet) {
        self.tintColor = style.borderColor.asUIColor
        style.statesStyle.forEach { style in
            var dictionary = [String: Any]()
            let font = UIFont(name: style.textFont.name , size: CGFloat(style.textSize)) ?? .none
            dictionary[NSForegroundColorAttributeName] = style.textColor.asUIColor
            font.apply { dictionary[NSFontAttributeName] = $0 }
            
            self.setTitleTextAttributes(dictionary, for: style.controlState)
        }
    }
    
}
