//
//  Models.swift
//  MapShare
//
//  Created by Edward Arenberg on 6/13/23.
//

import Foundation
import CoreLocation

struct Pin : Codable, Identifiable, Equatable {
  private(set) var id = UUID()
  let title : String
  let lat : Double
  let lon : Double
  var loc : CLLocationCoordinate2D {
    CLLocationCoordinate2D(latitude: lat, longitude: lon)
  }

}

struct MapLocation: Identifiable {
  let id = UUID()
  let latitude: Double
  let longitude: Double
}

extension MapLocation {
  var coordinate: CLLocationCoordinate2D {
    CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
}

