//
//  Component.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 1/27/17.
//
//
import Foundation

public enum RootComponent<MessageType> {
    
    case simple(component: Component<MessageType>)
    case withNavigationBar(NavigationBar<MessageType>, component: Component<MessageType>)
    case withTabBar(TabBar<MessageType>, component: Component<MessageType>)
    
}

public enum Component<MessageType> {
    
    case button(ButtonProperties<MessageType>, StyleSheet<ButtonStyleSheet>, Layout)
    case label(LabelProperties, StyleSheet<LabelStyleSheet>, Layout)
    case mapView(MapProperties, StyleSheet<EmptyStyleSheet>, Layout)
    case imageView(Image, StyleSheet<EmptyStyleSheet>, Layout)
    case container([Component<MessageType>], StyleSheet<EmptyStyleSheet>, Layout)
    case table(TableProperties<MessageType>, StyleSheet<TableStyleSheet>, Layout)
    //    case custom(ComponentProtocol, ComponentRenderer)
    
    public var layout: Layout {
        switch self {
            
        case .button(_, _, let layout):
            return layout
            
        case .label(_, _, let layout):
            return layout
            
        case .mapView(_, _, let layout):
            return layout
            
        case .imageView(_, _, let layout):
            return layout
            
        case .container(_, _, let layout):
            return layout
            
        case .table(_, _, let layout):
            return layout
            
        }
    }
    
}

extension Component {
    
    public func map<NewMessageType>(_ transform: @escaping (MessageType) -> NewMessageType) -> Component<NewMessageType> {
        switch self {
            
        case .button(let properties, let style, let layout):
            return .button(properties.map(transform), style, layout)
            
        case .label(let properties, let style, let layout):
            return .label(properties, style, layout)
            
        case .mapView(let properties, let style, let layout):
            return .mapView(properties, style, layout)
            
        case .imageView(let image, let style, let layout):
            return .imageView(image, style, layout)
            
        case .container(let children, let style, let layout):
            return .container(children.map { $0.map(transform) }, style, layout)
            
        case .table(let properties, let style, let layout):
            return .table(properties.map(transform), style, layout)
            
        }
    }
    
}

public func container<MessageType>(
    children: [Component<MessageType>] = [],
    style: StyleSheet<EmptyStyleSheet> = EmptyStyleSheet.`default`,
    layout: Layout = Layout()) -> Component<MessageType> {
    return .container(children, style, layout)
}
