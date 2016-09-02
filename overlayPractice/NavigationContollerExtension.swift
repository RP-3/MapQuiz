//
//  NavigationContollerExtension.swift
//  MapQuiz
//
//  Created by Anna Rogers on 9/1/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import UIKit

extension UINavigationController {
    override public func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.Portrait, .PortraitUpsideDown]
    }
}

