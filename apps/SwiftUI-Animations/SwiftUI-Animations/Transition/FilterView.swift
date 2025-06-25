//
//  FilterView.swift
//  SwiftUI-Animations
//
//  Created by Renjun Li on 2025/6/25.
//

import SwiftUI

struct FilterView: View {
    @Binding var selectedSports: Set<Sport>
    var isShown: Bool
    
    private let sports = Sport.allCases
    var horizontalShift = CGFloat.zero
    var verticalShift = CGFloat.zero
    
    private let filterTransition = AnyTransition.modifier(
        active: FilterModifier(active: true),
        identity: FilterModifier(active: false)
    )
    
    var body: some View {
        var horizontalShift = CGFloat.zero
        var verticalShift = CGFloat.zero
        ZStack(alignment: .topLeading) {
            if isShown {
                ForEach(sports, id: \.self) { sport in
                    Button {
                        onSelected(sport)
                    } label: {
                        item(for: sport)
                            .padding(.horizontal, 4)
                            .padding(.top, 8)
                            .alignmentGuide(.leading) { dimension in
                                if abs(horizontalShift - dimension.width) > UIScreen.main.bounds.width {
                                    horizontalShift = 0
                                    verticalShift -= dimension.height
                                }
                                let currentSift = horizontalShift
                                horizontalShift = sport == sports.last ? 0 : horizontalShift - dimension.width
                                return currentSift
                            }
                            .alignmentGuide(.top) { _ in
                                let currentShift = verticalShift
                                verticalShift = sport == sports.last ? 0 : verticalShift
                                return currentShift
                            }
                    }
                    .transition(
                        .asymmetric(
                            insertion: filterTransition,
                            removal: .scale
                        )
                    )
                }
            }
        }
        .padding(.top, isShown ? 24 : 0)
    }
    
    func item(for sport: Sport) -> some View {
        Text(sport.string)
            .frame(height: 48)
            .foregroundStyle(selectedSports.contains(sport) ? .white : .primary)
            .padding(.horizontal, 36)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: Constants.cornersRadius)
                        .fill(
                            selectedSports.contains(sport)
                            ? Constants.orange
                            : Color(uiColor: UIColor.secondarySystemBackground)
                        )
                        .shadow(radius: 2)
                    RoundedRectangle(cornerRadius: Constants.cornersRadius)
                        .strokeBorder(Constants.orange, lineWidth: 3)
                }
            }
    }
    
    private func onSelected(_ sport: Sport) {
        if selectedSports.contains(sport) {
            selectedSports.remove(sport)
        } else {
            selectedSports.insert(sport)
        }
    }
}


struct FilterModifier: ViewModifier {
    var active: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(active ? 0.75 : 1)
            .rotationEffect(.degrees(active ? .random(in: -25...25) : 0), anchor: .center)
    }
}
