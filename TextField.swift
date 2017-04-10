//
//  TextField.swift
//  PortalView
//
//  Created by Juan Franco Caracciolo on 4/10/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Foundation

public struct TextFieldProperties<MessageType> {
    
    public var text: String
    public var textAfterLayout: String?
    public var onEvents: OnTextFieldEvents<MessageType>
    
    fileprivate init(
        text: String = "",
        textAfterLayout: String? = .none,
        onEvents: OnTextFieldEvents<MessageType> = OnTextFieldEvents() ) {
        self.text = text
        self.textAfterLayout = textAfterLayout
        self.onEvents = onEvents
    }
    
    public func map<NewMessageType>(_ transform: (MessageType) -> NewMessageType) -> TextFieldProperties<NewMessageType> {
        return TextFieldProperties<NewMessageType>(
            text: self.text,
            textAfterLayout: self.textAfterLayout,
            onEvents: self.onEvents.map(transform)
        )
    }
    
}

public struct OnTextFieldEvents<MessageType> {
    
    public var onEditingBegin: MessageType?
    public var onEditingChanged: MessageType?
    public var onEditingEnd: MessageType?
    
    public init(
        onEditingBegin: MessageType? = .none,
        onEditingChanged: MessageType? = .none,
        onEditingEnd: MessageType? = .none) {
        self.onEditingBegin = onEditingBegin
        self.onEditingChanged = onEditingChanged
        self.onEditingEnd = onEditingEnd
    }
    
    public func map<NewMessageType>(_ transform: (MessageType) -> NewMessageType) -> OnTextFieldEvents<NewMessageType> {
        return OnTextFieldEvents<NewMessageType>(
            onEditingBegin: onEditingBegin.map(transform),
            onEditingChanged: onEditingChanged.map(transform),
            onEditingEnd: onEditingEnd.map(transform)
        )
    }
    
}

public func textField<MessageType>(
    properties: TextFieldProperties<MessageType> = TextFieldProperties(),
    style: StyleSheet<TextFieldStyleSheet> = TextFieldStyleSheet.`default`,
    layout: Layout = layout()) -> Component<MessageType> {
    return .textField(properties, style, layout)
}

public func properties<MessageType>(configure: (inout TextFieldProperties<MessageType>) -> ()) -> TextFieldProperties<MessageType> {
    var properties = TextFieldProperties<MessageType>()
    configure(&properties)
    return properties
}

// MARK: - Style sheet

public struct TextFieldStyleSheet {
    
    static let `default` = StyleSheet<TextFieldStyleSheet>(component: TextFieldStyleSheet())
    
    public var textColor: Color
    public var textFont: Font
    public var textSize: UInt
    public var textAligment: TextAligment
    public init(
        textColor: Color = .black,
        textFont: Font = defaultFont,
        textSize: UInt = defaultButtonFontSize,
        textAligment: TextAligment = .natural ) {
        self.textColor = textColor
        self.textFont = textFont
        self.textSize = textSize
        self.textAligment = textAligment
    }
    
}

public func textFieldStyleSheet(configure: (inout BaseStyleSheet, inout TextFieldStyleSheet) -> () = { _ in }) -> StyleSheet<TextFieldStyleSheet> {
    var base = BaseStyleSheet()
    var component = TextFieldStyleSheet()
    configure(&base, &component)
    return StyleSheet(component: component, base: base)
}
