//
//  TicketsInfo.swift
//  SwiftUI-Animations
//
//  Created by Renjun Li on 2025/6/25.
//

import Foundation

struct TicketsInfo: Hashable {
  let type: String
  let price: Int
  let left: Int

  func hash(into hasher: inout Hasher) {
    hasher.combine(type)
    hasher.combine(price)
    hasher.combine(left)
  }
}
