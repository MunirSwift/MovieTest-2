//
//  MySearchBar.swift
//  MovieTest
//
//  Created by Rydus on 22/04/2019.
//  Copyright © 2019 Rydus. All rights reserved.
//  https://medium.com/@maximbilan/ios-left-aligned-uisearchbar-b51ef36b6e1b
//  offset play

import UIKit

class MySearchBar: UISearchBar, UISearchBarDelegate {

    override public var placeholder:String? {
        didSet {
            if #available(iOS 9.0, *) {
                if let text = placeholder {
                    if text.last! != " " {
                        let attr = UITextField.appearance(whenContainedInInstancesOf:[MySearchBar.self]).defaultTextAttributes
                        let maxSize = CGSize(width:self.bounds.size.width - 86, height:40)
                        let widthText = text.boundingRect( with: maxSize, options: .usesLineFragmentOrigin, attributes:attr, context:nil).size.width
                        let widthSpace = " ".boundingRect( with: maxSize, options: .usesLineFragmentOrigin, attributes:attr, context:nil).size.width
                        let spaces = floor((maxSize.width - widthText) / widthSpace)
                        let newText = text + ((Array(repeating: " ", count: Int(spaces)).joined(separator:"")))
                        if newText != text {
                            placeholder = newText
                        }
                    }
                }
            }
        }
    }
}
