//
//  ComponentRenderer.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 4/10/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

internal struct ComponentRenderer<MessageType, CustomComponentRendererType: UIKitCustomComponentRenderer>: UIKitRenderer
    where CustomComponentRendererType.MessageType == MessageType {
    
    typealias CustomComponentRendererFactory = () -> CustomComponentRendererType
    
    let component: Component<MessageType>
    let rendererFactory: CustomComponentRendererFactory
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<MessageType> {
        switch component {
            
        case .button(let properties, let style, let layout):
            return ButtonRenderer(properties: properties, style: style, layout: layout)
                .render(with: layoutEngine, isDebugModeEnabled: isDebugModeEnabled)
            
        case .label(let properties, let style, let layout):
            return LabelRenderer(properties: properties, style: style, layout: layout)
                .render(with: layoutEngine, isDebugModeEnabled: isDebugModeEnabled)
            
        case .textField(let properties, let style, let layout):
            return TextFieldRenderer(properties: properties, style: style, layout: layout)
                .render(with: layoutEngine, isDebugModeEnabled: isDebugModeEnabled)
            
        case .mapView(let properties, let style, let layout):
            return MapViewRenderer(properties: properties, style: style, layout: layout)
                .render(with: layoutEngine, isDebugModeEnabled: isDebugModeEnabled)
            
        case .imageView(let image, let style, let layout):
            return ImageViewRenderer(image: image, style: style, layout: layout)
                .render(with: layoutEngine, isDebugModeEnabled: isDebugModeEnabled)
            
        case .container(let children, let style, let layout):
            return ContainerRenderer(
                children: children,
                style: style,
                layout: layout,
                rendererFactory: rendererFactory
            ).render(with: layoutEngine, isDebugModeEnabled: isDebugModeEnabled)
            
        case .table(let properties, let style, let layout):
            return TableRenderer(
                properties: properties,
                style: style,
                layout: layout,
                rendererFactory: rendererFactory
            ).render(with: layoutEngine, isDebugModeEnabled: isDebugModeEnabled)
            
        case .touchable(let gesture, let child):
            return TouchableRenderer(child: child, gesture: gesture, rendererFactory: rendererFactory)
                .render(with: layoutEngine, isDebugModeEnabled: isDebugModeEnabled)
            
        case .segmented(let segments, let style, let layout):
            return SegmentedRenderer(segments: segments, style: style, layout: layout)
                .render(with: layoutEngine, isDebugModeEnabled: isDebugModeEnabled)
            
        case .collection(let properties, let style, let layout):
            return CollectionRenderer(
                properties: properties,
                style: style,
                layout: layout,
                rendererFactory: rendererFactory
            ).render(with: layoutEngine, isDebugModeEnabled: isDebugModeEnabled)
            
        case .carousel(let properties, let style, let layout):
            return CarouselRenderer(
                properties: properties,
                style: style,
                layout: layout,
                rendererFactory: rendererFactory
            ).render(with: layoutEngine, isDebugModeEnabled: isDebugModeEnabled)
            
        case .progress(let progress, let style, let layout):
            return ProgressRenderer(progress: progress, style: style, layout: layout)
                .render(with: layoutEngine, isDebugModeEnabled: isDebugModeEnabled)
            
        case .custom(let componentIdentifier, let layout):
            let customComponentContainerView = UIView()
            layoutEngine.apply(layout: layout, to: customComponentContainerView)
            let mailbox = Mailbox<MessageType>()
            return Render(view: customComponentContainerView, mailbox: mailbox) {
                self.rendererFactory().renderComponent(
                    withIdentifier: componentIdentifier,
                    inside: customComponentContainerView,
                    dispatcher: mailbox.dispatch
                )
            }
            
        case .spinner(let isActive, let style, let layout):
            return SpinnerRenderer(
                isActive: isActive,
                style: style,
                layout: layout
            ).render(with: layoutEngine, isDebugModeEnabled: isDebugModeEnabled)
            
        }
    }
    
}
