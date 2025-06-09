//
//  HomeViewModel.swift
//  AsyncAll
//
//  Created by Renjun Li on 2025/6/9.
//

import SwiftUI
import Foundation

class HomeViewModel: ObservableObject {
    let list: [MenunItem]
    
    init() {
        self.list = [
            .init(page: .whyModernSwiftConcurrency),
            .init(page: .getStartedWitgAsyncWait),
            .init(page: .asyncsequence),
            .init(page: .asyncStream),
            .init(page: .intermediateAsyncAwaiCheckedcontinuation),
            .init(page: .testAyncchronous),
            .init(page: .taskGroup),
            .init(page: .actors),
            .init(page: .globalActor),
        ]
    }
}

struct MenunItem: Identifiable {
    var id: String {
        page.rawValue
    }
    var name: String {
        page.rawValue
    }
    let page: Page
}

enum Page: String {
    case whyModernSwiftConcurrency
    case getStartedWitgAsyncWait
    case asyncsequence
    case asyncStream
    case intermediateAsyncAwaiCheckedcontinuation
    case testAyncchronous
    case taskGroup
    case actors
    case globalActor
}
