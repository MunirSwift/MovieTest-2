//
//  MainMovieParser.swift
//  MovieTest
//
//  Created by Rydus on 23/04/2019.
//  Copyright © 2019 Rydus. All rights reserved.
//

import UIKit

class MainMovieParser {
    
    static func getTitleMovie(keyword:String, arr:NSArray)->NSArray {
        let namePredicate = NSPredicate(format: "title BEGINSWITH[c] %@",keyword)
        return arr.filter { namePredicate.evaluate(with: $0) } as NSArray
    }
}
