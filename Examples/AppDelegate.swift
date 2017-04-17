//
//  AppDelegate.swift
//  Examples
//
//  Created by Guido Marucci Blas on 2/18/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit
import PortalView

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let presenter = UIKitComponentManager<String, VoidCustomComponentRenderer<String>>(window: window!, customComponentRenderer: VoidCustomComponentRenderer())
        presenter.isDebugModeEnabled = false
        _ = presenter.present(component:  dynamicHeightTable(), with: .simple, modally: false)
        
        window?.makeKeyAndVisible()
        return true
    }
    
}

