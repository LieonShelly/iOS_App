//
//  ChatLocationDelegate.swift
//  AsyncAll
//
//  Created by Renjun Li on 2025/6/12.
//

import Foundation
import CoreLocation
import Combine
import UIKit

class ChatLocationDelegate: NSObject, CLLocationManagerDelegate {
  typealias LocationContinuation = CheckedContinuation<CLLocation, Error>
  private var continuation: LocationContinuation?
  
  init(manager: CLLocationManager, continuation: LocationContinuation? = nil) {
    self.continuation = continuation
    super.init()
    manager.delegate = self
    manager.requestWhenInUseAuthorization()
  }
  
  deinit {
    continuation?.resume(throwing: CancellationError())
  }
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    switch manager.authorizationStatus {
    case .notDetermined:
      break
    case .authorizedAlways, .authorizedWhenInUse:
      manager.startUpdatingLocation()
    default:
      continuation?.resume(throwing: "The app isn't authorized to use location data")
      continuation = nil
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.first else { return }
    continuation?.resume(returning: location)
    continuation = nil
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
    continuation?.resume(throwing: error)
    continuation = nil
  }
}
