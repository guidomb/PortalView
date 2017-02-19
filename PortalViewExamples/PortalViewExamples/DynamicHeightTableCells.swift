//
//  DynamicHeightTableCells.swift
//  PortalViewExamples
//
//  Created by Guido Marucci Blas on 2/18/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Foundation
import PortalView

extension Array {
    
    func sample() -> Element {
        return self[Int(arc4random_uniform(UInt32(self.count)))]
    }
    
}

func tableCellComponent(index: Int, text: String, backgroundColor: Color, itemMaxHeight: UInt) -> Component<String> {
    return container(
        children: [
            label(
                text: "Text for cell \(index)",
                style: labelStyleSheet() { base, label in
                    label.textColor = .white
                },
                layout: layout() {
                    $0.flex = flex() {
                        $0.grow = .one
                    }
                }
            ),
            label(
                text: text,
                style: labelStyleSheet() { base, label in
                    label.textColor = .white
                    label.numberOfLines = 3
                },
                layout: layout() {
                    $0.flex = flex() {
                        $0.grow = .two
                    }
                }
            )
        ],
        style: styleSheet() {
            $0.backgroundColor = backgroundColor
        },
        layout: layout() {
            $0.height = Dimension(maximum: itemMaxHeight)
            $0.flex = flex() {
                $0.direction = .column
            }
        }
    )
}

func dynamicHeightTable<String>() -> Component<String> {
    let backgroundColors = [
        Color.blue,
        Color.red,
        Color.green,
        Color.gray
    ]
    
    let texts = [
        "This is a simple text",
        "This is a simple text but a little bit longer you know!",
        "This is a large text and it is going to be as large as I want it to be because that is how rad I am. Well it is not that large!"
    ]
    
    let content = (0 ... 20).map { ($0, texts.sample(), backgroundColors.sample()) }
    
    func cellRenderer(itemMaxHeight: UInt) -> String {
        let b = TableItemRender(
            component: button(text: "", onTap: ""),
            typeIdentifier: "Cell"
        )
        let c = b.typeIdentifier
        return c
    }
    
//    let items: [TableItemProperties<String>] = content.map { index, text, backgroundColor in
//        return tableItem(height: 90) { itemMaxHeight in
//            let a =
//            let b = TableItemRender<String>(component: a, typeIdentifier: "Cell")
//            return b
//        }
//    }
    
    return table(
        items: [],
        style: tableStyleSheet() { base, table in
            table.separatorColor = .black
        },
        layout: layout() {
            $0.flex = flex() {
                $0.grow = .one
            }
        }
    )
}
