//
//  NavigationBar.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 1/27/17.
//
//

import Foundation

public enum NavigationBarTitle<MessageType> {
    
    case text(String)
    case image(Image)
    case component(Component<MessageType>)
    
}

public struct NavigationBarProperties<MessageType> {
    
    public let title: NavigationBarTitle<MessageType>
    public let hideBackButtonTitle: Bool
    
    internal init(title: NavigationBarTitle<MessageType>, hideBackButtonTitle: Bool = false) {
        self.title = title
        self.hideBackButtonTitle = hideBackButtonTitle
    }
    
}

public struct NavigationBar<MessageType> {
    
    public let properties: NavigationBarProperties<MessageType>
    public let style: StyleSheet<NavigationBarStyleSheet>
    
}

public func navigationBar<MessageType>(
    properties: NavigationBarProperties<MessageType>,
    style: StyleSheet<NavigationBarStyleSheet> = navigationBarStyleSheet()) -> NavigationBar<MessageType> {
    return NavigationBar(properties: properties, style: style)
}

public func navigationBar<MessageType>(
    title: String,
    style: StyleSheet<NavigationBarStyleSheet> = navigationBarStyleSheet()) -> NavigationBar<MessageType> {
    return NavigationBar(properties: NavigationBarProperties(title: .text(title)), style: style)
}

public func navigationBar<MessageType>(
    title: Image,
    style: StyleSheet<NavigationBarStyleSheet> = navigationBarStyleSheet()) -> NavigationBar<MessageType> {
    let properties = NavigationBarProperties<MessageType>(title: .image(title))
    return NavigationBar(properties: properties, style: style)
}

// MARK: - Style sheet

public let defaultNavigationBarTitleFontSize: UInt = 17

public struct NavigationBarStyleSheet {
    
    static let `default` = StyleSheet<NavigationBarStyleSheet>(component: NavigationBarStyleSheet())
    
    public var tintColor: Color
    public var titleTextColor: Color
    public var titleTextFont: Font
    public var titleTextSize: UInt
    public var isTranslucent: Bool
    public var statusBarStyle: StatusBarStyle
    
    public init(
        tintColor: Color = .black,
        titleTextColor: Color = .black,
        titleTextFont: Font = defaultFont,
        titleTextSize: UInt = defaultNavigationBarTitleFontSize,
        isTranslucent: Bool = true,
        statusBarStyle: StatusBarStyle = .`default`) {
        self.tintColor = tintColor
        self.titleTextFont = titleTextFont
        self.titleTextColor = titleTextColor
        self.titleTextSize = titleTextSize
        self.isTranslucent = isTranslucent
        self.statusBarStyle = statusBarStyle
    }
    
}

public func navigationBarStyleSheet(configure: (inout BaseStyleSheet, inout NavigationBarStyleSheet) -> () = { _ in }) -> StyleSheet<NavigationBarStyleSheet> {
    var base = BaseStyleSheet()
    var component = NavigationBarStyleSheet()
    configure(&base, &component)
    return StyleSheet(component: component, base: base)
}
