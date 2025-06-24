//
//  Event.swift
//  SwiftUI-Animations
//
//  Created by Renjun Li on 2025/6/24.
//

import Foundation

struct Event: Equatable, Identifiable, Hashable {
    static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: Int
    let team: Team
    let date: String
    let location: String
    let ticketsLeft: Int
}

extension Event {
    init(team: Team, location: String?, ticketsLeft: Int) {
        self.init(
            id: .randomId(),
            team: team,
            date: Date.random().formatted(date: .complete, time: .omitted),
            location: location ?? "",
            ticketsLeft: ticketsLeft
        )
    }
}

enum Sport: Int, CaseIterable {
    case football = 0, basketball, iceHockey, baseball, tennis
    var imageURL: URL? {
        URL(string: sportTypeImages[self.rawValue].appending("?fit=crop&w=600&q=80"))
    }
    var string: String {
        ["Football 🏈", "Basketball 🏀", "Ice Hockey 🏒", "Baseball ⚾", "Tennis 🎾"][self.rawValue]
    }
}

struct Team {
    let name: String
    let sport: Sport
    let description: String
}
