//
//  Segmented.swift
//  PortalView
//
//  Created by Cristian Ames on 4/4/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

public struct SegmentedProperties<MessageType> {
    
    public var segments: [SegmentProperties<MessageType>]
    public var selectedSegment: UInt
    
    fileprivate init(
        segments: [SegmentProperties<MessageType>] = [],
        selectedSegment: UInt = 0) {
        self.segments = segments
        self.selectedSegment = selectedSegment
    }
    
}

public enum SegmentContentType {
    
    case title(String)
    case image(Image)
    
}

public struct SegmentProperties<MessageType> {
    
    public let content: SegmentContentType
    public let onTap: MessageType?
    public let isEnabled: Bool
    
    fileprivate init(
        content: SegmentContentType,
        onTap: MessageType? = .none,
        isEnabled: Bool = true) {
        self.content = content
        self.onTap = onTap
        self.isEnabled = isEnabled
    }
    
}

public extension SegmentedProperties {
    
    public func map<NewMessageType>(_ transform: @escaping (MessageType) -> NewMessageType) -> SegmentedProperties<NewMessageType> {
        let newSegments = segments.map {
            return SegmentProperties(
                content: $0.content,
                onTap: $0.onTap.map(transform),
                isEnabled: $0.isEnabled
            )
        }
        return SegmentedProperties<NewMessageType>(
            segments: newSegments,
            selectedSegment: self.selectedSegment
        )
    }
    
}

public func segmented<MessageType>(
    properties: SegmentedProperties<MessageType> = SegmentedProperties(),
    style: StyleSheet<SegmentedStyleSheet> = SegmentedStyleSheet.default,
    layout: Layout = layout()) -> Component<MessageType> {
    return .segmented(properties, style, layout)
}

public func segmented<MessageType>(
    segments: [SegmentProperties<MessageType>] = [],
    selectedSegment: UInt = 0,
    style: StyleSheet<SegmentedStyleSheet> = SegmentedStyleSheet.default,
    layout: Layout = layout()) -> Component<MessageType> {
    return .segmented(SegmentedProperties(segments: segments, selectedSegment: selectedSegment), style, layout)
}

public func segment<MessageType>(
    title: String,
    onTap: MessageType? = .none,
    isEnabled: Bool = true) -> SegmentProperties<MessageType> {
    return SegmentProperties(content: .title(title), onTap: onTap, isEnabled: isEnabled)
}

public func segment<MessageType>(
    image: Image,
    onTap: MessageType? = .none,
    isEnabled: Bool = true) -> SegmentProperties<MessageType> {
    return SegmentProperties(content: .image(image), onTap: onTap, isEnabled: isEnabled)
}

public func properties<MessageType>(configure: (inout SegmentedProperties<MessageType>) -> ()) -> SegmentedProperties<MessageType> {
    var properties = SegmentedProperties<MessageType>()
    configure(&properties)
    return properties
}

// MARK:- Style sheet

public struct SegmentedStyleSheet {
    
    public static let `default` = StyleSheet<SegmentedStyleSheet>(component: SegmentedStyleSheet())
    
    public var borderColor: Color
    public var statesStyle: [SegmentedStateStyleSheet]
    
    public init(
        borderColor: Color = .blue,
        statesStyle: [SegmentedStateStyleSheet] = []) {
        self.borderColor = borderColor
        self.statesStyle = statesStyle
    }
    
}

public struct SegmentedStateStyleSheet {
    
    public var textFont: Font
    public var textSize: UInt
    public var textColor: Color
    internal var controlState: UIControlState
    
    public init(
        textFont: Font = defaultFont,
        textSize: UInt = defaultButtonFontSize,
        textColor: Color = .clear,
        controlState: UIControlState = .normal) {
        self.textFont = textFont
        self.textSize = textSize
        self.textColor = textColor
        self.controlState = controlState
    }
    
}

public func segmentedStyleSheet(configure: (inout BaseStyleSheet, inout SegmentedStyleSheet) -> ()) -> StyleSheet<SegmentedStyleSheet> {
    var base = BaseStyleSheet()
    var custom = SegmentedStyleSheet()
    configure(&base, &custom)
    return StyleSheet(component: custom, base: base)
}

public func statesStyle(state: UIControlState = UIControlState.normal, configure: (inout SegmentedStateStyleSheet) -> ()) -> SegmentedStateStyleSheet {
    var state = SegmentedStateStyleSheet(controlState: state)
    configure(&state)
    return state
}
