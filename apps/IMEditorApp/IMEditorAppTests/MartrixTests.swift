//
//  MartrixTests.swift
//  IMEditorAppTests
//
//  Created by Renjun Li on 2025/4/13.
//

import Testing
import Foundation
import simd
@testable import IMEditorApp

@Suite("Martrix")
struct MartrixTests {
    @Test func testScreenToMetalMartrix() async throws {
        let screenSize: CGSize = CGSize(width: 100, height: 100)
        let martrix = Martrix.screenToMetalMartrix(screenSize)
        
        let originInSc = SIMD3<Float>(0,0,1)
        
        assert(martrix * originInSc == SIMD3<Float>(-1, 1, 1))
    }
}
