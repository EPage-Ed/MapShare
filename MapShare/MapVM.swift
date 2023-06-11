//
//  MapVM.swift
//  MapShare
//
//  Created by Edward Arenberg on 6/10/23.
//

import Observation
import Combine
import GroupActivities

@Observable
class MapVM {
  var pins = [Pin]()

  var groupSession: GroupSession<MapActivity>? = nil
  @ObservationIgnored var messenger: GroupSessionMessenger? = nil
  @ObservationIgnored var journal: GroupSessionJournal? = nil

  var subscriptions = Set<AnyCancellable>()
  var tasks = Set<Task<Void, Never>>()
  
  func reset() {
    pins = []
    
    messenger = nil
    journal = nil
    tasks.forEach { $0.cancel() }
    tasks = []
    subscriptions = []
    if groupSession != nil {
        groupSession?.leave()
        groupSession = nil
        self.startSharing()
    }
  }

  func addPin(pin: Pin) {
    pins.append(pin)
    if let messenger = messenger {
      Task {
        try? await messenger.send(PinMessage(pins: pins, count: pins.count))
      }
    }
  }

  func startSharing() {
    Task {
      do {
        _ = try await MapActivity().activate()
      } catch {
        print("Failed to activate DrawTogether activity: \(error)")
      }
    }
  }
  
  func configureGroupSession(_ groupSession: GroupSession<MapActivity>) {
    pins = []
    
    self.groupSession = groupSession
    let messenger = GroupSessionMessenger(session: groupSession)
    self.messenger = messenger
    let journal = GroupSessionJournal(session: groupSession)
    self.journal = journal
    
    groupSession.$state
      .sink { state in
        if case .invalidated = state {
          self.groupSession = nil
          self.reset()
        }
      }
      .store(in: &subscriptions)
    
    groupSession.$activeParticipants
      .sink { activeParticipants in
        let newParticipants = activeParticipants.subtracting(groupSession.activeParticipants)
        
        Task {
          try? await messenger.send(PinMessage(pins: self.pins, count: self.pins.count), to: .only(newParticipants))
        }
      }
      .store(in: &subscriptions)
    
      let task = Task {
      for await (message, _) in messenger.messages(of: PinMessage.self) {
        handle(message)
      }
    }
    tasks.insert(task)
    
    groupSession.join()
  }
  
  func handle(_ message: PinMessage) {
    guard message.count > self.pins.count else { return }
      self.pins = message.pins
  }

}

