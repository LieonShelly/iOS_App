//
//  SharedData.swift
//  App
//
//  Created by Renjun Li on 2024/8/15.
//

import SwiftUI

@Observable
class SharedData {
    var activePage: Int = 1
    var isExpanded: Bool = false
    var canPullUp: Bool = false
    var canPullDown: Bool = false
    var mainOffset: CGFloat = 0
    var progress: CGFloat = 0
    var photoScrollOffset: CGFloat = 0
    var selectedCategory: String = "Year"
}
