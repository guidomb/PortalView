//
//  ComponentRenderer.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 2/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Foundation

extension Component: UIKitRenderer {
  
  func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<MessageType> {
    switch self {
      
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
      return ContainerRenderer(children: children, style: style, layout: layout)
        .render(with: layoutEngine, isDebugModeEnabled: isDebugModeEnabled)
      
    case .table(let properties, let style, let layout):
      return TableRenderer(properties: properties, style: style, layout: layout)
        .render(with: layoutEngine, isDebugModeEnabled: isDebugModeEnabled)
      
    case .touchable(let gesture, let child):
      return TouchableRenderer(child: child, gesture: gesture)
        .render(with: layoutEngine, isDebugModeEnabled: isDebugModeEnabled)
      
    case .segmented(let segments, let style, let layout):
      return SegmentedRenderer(segments: segments, style: style, layout: layout)
        .render(with: layoutEngine, isDebugModeEnabled: isDebugModeEnabled)
    }
    
    
  }
  
}
