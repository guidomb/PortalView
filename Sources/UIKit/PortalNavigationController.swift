//
//  PortalNavigationController.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 2/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

public final class PortalNavigationController: UINavigationController {
    
    private let statusBarStyle: UIStatusBarStyle
    
    init(rootViewController: UIViewController, statusBarStyle: UIStatusBarStyle = .`default`) {
        self.statusBarStyle = statusBarStyle
        super.init(nibName: nil, bundle: nil)
        pushViewController(rootViewController, animated: false)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
}
