//
//  MapShareApp.swift
//  MapShare
//
//  Created by Edward Arenberg on 6/10/23.
//

import SwiftUI
import SwiftData

@main
struct MapShareApp: App {
  
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .modelContainer(for: Item.self)
  }
}
