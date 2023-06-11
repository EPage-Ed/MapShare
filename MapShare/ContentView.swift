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

struct Pin : Codable, Identifiable, Equatable {
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
  @State private var visibleRegion : MKCoordinateRegion? = nil
  @State private var selectedPin: Pin? = nil
  @StateObject var groupStateObserver = GroupStateObserver()


  var body: some View {
    
    ZStack(alignment: .bottomTrailing) {
      VStack {
        Map(position: $position) {
          ForEach(mapVM.pins) { pin in
            Annotation(pin.title, coordinate: pin.loc) {
              ZStack {
                Circle()
                  .fill(.pink.opacity(0.4))
                Image(systemName: "mappin")
                  .font(.largeTitle)
                  .foregroundColor(.red)
                  .padding(8)
              }
              .onTapGesture {
                print("Tap \(pin)")
                selectedPin = pin // MKMapItem(placemark: MKPlacemark(coordinate: pin.loc))
              }
            }


          }
          
        }
        .mapStyle(.hybrid(elevation: .realistic, pointsOfInterest: .all))
        .safeAreaInset(edge: .bottom) {
          HStack {
            Spacer()
            VStack(spacing: 0) {
              if let selectedPin {
                ItemView(pin: selectedPin)
//                ItemView(selectedResult: selectedPin)
                  .frame(height: 128)
                  .clipShape(RoundedRectangle(cornerRadius: 10))
                  .padding()
              }
            }
          }
        }
        .mapControls {
            MapCompass()
            MapScaleView()
        }
        .onMapCameraChange { context in
          visibleRegion = context.region
          print(context.region.center)
        }
      }
      .edgesIgnoringSafeArea(.all)
      
      
      VStack {
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
              .foregroundColor(.orange)
          }
          
        }
      }
      .padding()
    }
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
}

struct ItemView: View {
  @State private var lookAroundScene: MKLookAroundScene?
//  var selectedResult : MKMapItem
  var pin : Pin
  
  func getLookAroundScene() {
    lookAroundScene = nil
    Task {
      let request = MKLookAroundSceneRequest(coordinate: pin.loc)
      lookAroundScene = try? await request.scene
    }
  }
  
  var body: some View {
    LookAroundPreview(initialScene: lookAroundScene)
      .overlay(alignment: .bottomTrailing) {
        Text("Look Around")
      }
      .onAppear {
        getLookAroundScene()
      }
      .onChange(of: pin) {
        getLookAroundScene()
      }
  }
}

#Preview {
  ContentView()
    .modelContainer(for: Item.self, inMemory: true)
}
