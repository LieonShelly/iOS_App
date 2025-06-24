//
//  BallView.swift
//  SwiftUI-Animations
//
//  Created by Renjun Li on 2025/6/24.
//

import SwiftUI

struct BallView: View {
    @Binding var pullToRefresh: PullToRefresh
    
    var body: some View {
        switch pullToRefresh.state {
        case .ongoing, .preparingFinish:
            JumpingBallView(pullToRefresh: $pullToRefresh)
        case .pulling, .finishing:
            RollingBallView(pullToRefresh: $pullToRefresh)
        default: EmptyView()
        }
    }
}

struct Ball: View {
    var body: some View {
        Image("basketball_ball")
            .resizable()
            .frame(
                width: Constants.ballSize,
                height: Constants.ballSize
            )
    }
}

struct RollingBallView: View {
    @Binding var pullToRefresh: PullToRefresh
    private let shadowHeight: CGFloat = 5
    @State private var rollOutOffset: CGFloat = 0
    @State private var rollOutRotaion: CGFloat = 0
    private let bezierCurve: Animation = .timingCurve(0.24, 1.4, 1, -1, duration: 1)
    private let initialOffset = -UIScreen.halfWidth - Constants.ballSize
    
    var body: some View {
        let rollInOffset = initialOffset + (pullToRefresh.progress * -initialOffset)
        let rollInRotation = pullToRefresh.progress * .pi * 4
        
        ZStack {
            Ellipse()
                .fill(Color.gray.opacity(0.4))
                .frame(
                    width: Constants.ballSize * 0.8,
                    height: shadowHeight)
                .offset(y: -Constants.ballSpacing - shadowHeight / 2)
            
            Ball()
                .rotationEffect(Angle(radians: pullToRefresh.state == .finishing ? rollOutRotaion : rollInRotation), anchor: .center)
                .offset(y: -Constants.ballSize / 2 - Constants.ballSpacing)
        }
        .animation(bezierCurve, value: pullToRefresh.progress)
        .offset(x: pullToRefresh.state == .finishing ? rollOutOffset : rollInOffset)
        .onAppear {
            animateRollingOut()
        }
    }
    
    private func animateRollingOut() {
        guard pullToRefresh.state == .finishing else {
            return
        }
        withAnimation(.easeIn(duration: Constants.timeForTheBallToRollOut)) {
            rollOutOffset = UIScreen.main.bounds.width
        }
        
        withAnimation(.linear(duration: Constants.timeForTheBallToRollOut)) {
            rollOutRotaion = .pi * 4
        }
    }
}

struct JumpingBallView: View {
    @Binding var pullToRefresh: PullToRefresh
    @State private var isAnimating = false
    @State private var roation = 0.0
    @State private var scale = 1.0
    private let shadowHeight = Constants.ballSize / 2
    
    var currentYOffset: CGFloat {
        isAnimating && pullToRefresh.state == .ongoing ?
        Constants.maxOffset - Constants.ballSize / 2 - Constants.ballSpacing :
        Constants.ballSize / 2 - Constants.ballSpacing
    }
    
    var body: some View {
        ZStack {
            Ellipse()
                .fill(
                    Color.gray.opacity(
                        pullToRefresh.state == .ongoing ? 0.4 : 0
                    )
                )
                .frame(width: Constants.ballSize, height: shadowHeight)
                .scaleEffect(isAnimating ? 1.2 : 0.3, anchor: .center)
                .offset(y: Constants.maxOffset - shadowHeight / 2 - Constants.ballSpacing)
                .opacity(isAnimating ? 1 : 0.3)
            
            Ball()
                .rotationEffect(
                    Angle(degrees: roation),
                    anchor: .center
                )
                .scaleEffect(x: 1 / scale, y: scale, anchor: .bottom)
                .offset(y: currentYOffset)
                .animation(.easeIn(duration: Constants.timeForTheBallToReturn), value: pullToRefresh.state == .preparingFinish)
        }
        .onAppear {
            animate()
        }
    }
    
    func animate() {
        withAnimation(.easeOut(duration: Constants.jumpDuration).repeatForever()) {
            isAnimating = true
        }
        
        withAnimation(.linear(duration: Constants.jumpDuration * 2).repeatForever()) {
            roation = 360
        }
        
        withAnimation(.easeOut(duration: Constants.jumpDuration).repeatForever()) {
            scale = 0.85
        }
    }
}
