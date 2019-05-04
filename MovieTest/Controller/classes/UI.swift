//
//  UI.swift
//  MovieTest
//
//  Created by Rydus on 20/04/2019.
//  Copyright © 2019 Rydus. All rights reserved.
//

import UIKit

final class UI {
    
    static func getStatusBarHeight()->CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
    
    static func getScreenSize()->CGRect {
        return UIScreen.main.bounds
    }
}
