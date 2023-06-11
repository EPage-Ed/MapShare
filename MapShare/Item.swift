//
//  Item.swift
//  MapShare
//
//  Created by Edward Arenberg on 6/10/23.
//

import Foundation
import SwiftData

//@Model
//final class Item {
//    var timestamp: Date
//    
//    init(timestamp: Date) {
//        self.timestamp = timestamp
//    }
//}


@Model
final class Item {
    let id = UUID()
    var timestamp: Date
    let title: String
    let lat:Double
    let lon:Double
   

    init(timestamp: Date, title: String,lat:Double,lon:Double) {
        self.timestamp = timestamp
        self.title = title
        self.lat = lat
        self.lon = lon
    }
}


