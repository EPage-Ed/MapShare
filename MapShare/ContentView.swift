//
//  ContentView.swift
//  MapShare
//
//  Created by Edward Arenberg on 6/10/23.
//

import SwiftUI
import SwiftData
import MapKit
import GroupActivities

extension CLLocationCoordinate2D {
  static let apple = CLLocationCoordinate2D(latitude: 37.334886, longitude: -122.008988)
}

struct Pin : Codable, Identifiable {
  private(set) var id = UUID()
  let title : String
  let lat : Double
  let lon : Double
  var loc : CLLocationCoordinate2D {
    CLLocationCoordinate2D(latitude: lat, longitude: lon)
  }
}

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var items: [Item]
  private var mapVM = MapVM()
  @State private var position: MapCameraPosition = .automatic
  @State private var addMode = false
  @State private var visibleRegion : MKCoordinateRegion? = nil
  @StateObject var groupStateObserver = GroupStateObserver()


  var body: some View {
    
    ZStack(alignment: .bottomTrailing) {
      VStack {
        //      Map(initialPosition: .userLocation(fallback: .automatic)) {
        Map(position: $position) {
          //      Map(initialPosition: .item(MKMapItem(placemark: MKPlacemark(coordinate: .apple))), bounds: .init(centerCoordinateBounds: .init(center: .apple, span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)))) {
          ForEach(mapVM.pins) { pin in
            Marker(pin.title, systemImage: "mappin", coordinate: pin.loc)
            //          Annotation(pin.title, coordinate: pin.loc) {
            //            Image(systemName: "mappin")
            //          }
          }
          
        }
        //        .ignoresSafeArea(.all)
        .onMapCameraChange { context in
          visibleRegion = context.region
          print(context.region.center)
        }
        
        
      }
      .edgesIgnoringSafeArea(.all)
      
      HStack {
        if mapVM.groupSession == nil && groupStateObserver.isEligibleForGroupSession {
          Button {
            mapVM.startSharing()
          } label: {
            Image(systemName: "person.2.fill")
          }
          .buttonStyle(.borderedProminent)
          .padding(.horizontal)
        }
        
        Button {
          mapVM.addPin(pin: Pin(title: "New Pin", lat: visibleRegion!.center.latitude, lon: visibleRegion!.center.longitude))
            let newItem = Item(timestamp: Date(), title: "New Pin", lat: visibleRegion!.center.latitude, lon: visibleRegion!.center.longitude)
            modelContext.insert(newItem)
            try? modelContext.save()
            print("NewItem",newItem.title,newItem.lat,newItem.lon)
        } label: {
          Image(systemName: "plus.circle")
            .font(.largeTitle)
//            Label("Add Item", systemImage: addMode ? "xmark" : "plus")
        }

      }
      .padding()
    }
      
      /*
      
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
              Label("Add Item", systemImage: addMode ? "xmark" : "plus")
            }
          }
        }
        Text("Select an item")
      }
    }
       */
    .onAppear {
      mapVM.pins = [
        Pin(title: "Apple", lat: CLLocationCoordinate2D.apple.latitude, lon: CLLocationCoordinate2D.apple.longitude)
      ]
    }
    .task {
      for await session in MapActivity.sessions() {
        mapVM.configureGroupSession(session)
      }
    }
  }
  
  /*
  private func addItem() {
    mapVM.addPin(pin: Pin(title: "New Pin", lat: visibleRegion!.center.latitude, lon: visibleRegion!.center.longitude))
//    addMode.toggle()
    /*
    withAnimation {
      let newItem = Item(timestamp: Date())
      modelContext.insert(newItem)
    }
     */
  }
  
  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        modelContext.delete(items[index])
      }
    }
  }
   */
}

#Preview {
  ContentView()
    .modelContainer(for: Item.self, inMemory: true)
}
