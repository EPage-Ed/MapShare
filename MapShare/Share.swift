//
//  Share.swift
//  MapShare
//
//  Created by Edward Arenberg on 6/10/23.
//

import Foundation
import GroupActivities
import AVFoundation

struct MapActivity : GroupActivity {
  static let activityIdentifier = "com.epage.MapShare.GroupNotes"

  var metadata: GroupActivityMetadata {
    var metadata = GroupActivityMetadata()
    
    metadata.title = "Map Together"
//    metadata.previewImage = UIImage(named: "ActivityImage")?.cgImage
    metadata.type = .generic
    
    return metadata
  }

}

struct PinMessage: Codable {
  let pins: [Pin]
  let count: Int
}



class MapShare {
  private var groupSession: GroupSession<MapActivity>?

  private func prepareSharePlay() {
    let activity = MapActivity()
    
    Task {
      switch await activity.prepareForActivation() {
      case .activationDisabled:
        break
      case .activationPreferred:
        try? await activity.activate()
      case .cancelled:
        break
      default: ()
      }
    }
  }
  
  private func listenForGroupSession() {
    Task {
      for await session in MapActivity.sessions() {
        groupSession = session
        session.join()
      }
    }
  }

}
