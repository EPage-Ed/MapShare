//
//  ContentView.swift
//  MapShare
//
//  Created by Edward Arenberg on 6/10/23.
//

import SwiftUI
import SwiftData
import MapKit

extension CLLocationCoordinate2D {
  static let apple = CLLocationCoordinate2D(latitude: 37.334886, longitude: -122.008988)
}

struct Pin : Identifiable {
  let id = UUID()
  let title : String
  let loc : CLLocationCoordinate2D
}

@Observable
class MapVM {
  var pins = [Pin]()
}

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var items: [Item]
  private var mapVM = MapVM()

  var body: some View {
    VStack {
//      Map(initialPosition: .userLocation(fallback: .automatic)) {
      Map(initialPosition: .item(MKMapItem(placemark: MKPlacemark(coordinate: .apple))), bounds: .init(centerCoordinateBounds: .init(center: .apple, span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)))) {
        ForEach(mapVM.pins) { pin in
          Marker(pin.title, systemImage: "mappin", coordinate: pin.loc)
//          Annotation(pin.title, coordinate: pin.loc) {
//            Image(systemName: "mappin")
//          }
        }
      }
      
      
      
      
      
      
      
      
      NavigationView {
        List {
          ForEach(items) { item in
            NavigationLink {
              Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
            } label: {
              Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
            }
          }
          .onDelete(perform: deleteItems)
        }
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            EditButton()
          }
          ToolbarItem {
            Button(action: addItem) {
              Label("Add Item", systemImage: "plus")
            }
          }
        }
        Text("Select an item")
      }
    }
    .onAppear {
      mapVM.pins = [
        Pin(title: "Apple", loc: .apple)
      ]
    }
  }
  
  private func addItem() {
    withAnimation {
      let newItem = Item(timestamp: Date())
      modelContext.insert(newItem)
    }
  }
  
  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        modelContext.delete(items[index])
      }
    }
  }
}

#Preview {
  ContentView()
    .modelContainer(for: Item.self, inMemory: true)
}
