import SwiftUI

struct CropOverlayView: View {
    @Binding var cropRect: CGRect
    @Binding var scale: CGFloat
    @Binding var translation: CGPoint
    
    
    let handleThickness: CGFloat = 30
    let minSize: CGFloat = 50
    @State private var initialRect: CGRect = .zero
    @State private var topEdge: CGFloat = .zero
    @State private var bottomEdge: CGFloat = .zero
    @State private var leftEdge: CGFloat = .zero
    @State private var rightEdge: CGFloat = .zero
    @State private var initialized: Bool = false
    @State private var translationInMove: CGPoint = .zero
    
    fileprivate func topline() -> some View {
        // 顶部边缘手柄
        Rectangle()
            .fill(Color.clear)
            .contentShape(Rectangle())
            .frame(width: rightEdge - leftEdge, height: handleThickness)
            .position(x: (leftEdge + rightEdge) / 2, y: topEdge)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let newTop = initialRect.minY + value.translation.height
                        if bottomEdge - newTop >= minSize {
                            topEdge = newTop
                            updateCropRect()
                        }
                    }
                    .onEnded { _ in
                        saveInitialRect()
                    }
            )
    }
    
    fileprivate func bottomLine() -> some View {
        // 底部边缘手柄
        Rectangle()
            .fill(Color.clear)
            .contentShape(Rectangle())
            .frame(width: rightEdge - leftEdge, height: handleThickness)
            .position(x: (leftEdge + rightEdge) / 2, y: bottomEdge)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let newBottom = initialRect.maxY + value.translation.height
                        // 确保不超过顶部边缘加上最小尺寸
                        if newBottom - topEdge >= minSize {
                            bottomEdge = newBottom
                            // 更新cropRect以保持同步
                            updateCropRect()
                        }
                    }
                    .onEnded { _ in
                        saveInitialRect()
                    }
            )
    }
    
    fileprivate func leftLine() -> some View {
        // 左侧边缘手柄
        Rectangle()
            .fill(Color.clear)
            .contentShape(Rectangle())
            .frame(width: handleThickness, height: bottomEdge - topEdge)
            .position(x: leftEdge, y: (topEdge + bottomEdge) / 2)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let newLeft = initialRect.minX + value.translation.width
                        // 确保不超过右侧边缘减去最小尺寸
                        if rightEdge - newLeft >= minSize {
                            leftEdge = newLeft
                            // 更新cropRect以保持同步
                            updateCropRect()
                        }
                    }
                    .onEnded { _ in
                        saveInitialRect()
                    }
            )
    }
    
    fileprivate func rightLine() -> some View {
        // 右侧边缘手柄
        Rectangle()
            .fill(Color.clear)
            .contentShape(Rectangle())
            .frame(width: handleThickness, height: bottomEdge - topEdge)
            .position(x: rightEdge, y: (topEdge + bottomEdge) / 2)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let newRight = initialRect.maxX + value.translation.width
                        // 确保不超过左侧边缘加上最小尺寸
                        if newRight - leftEdge >= minSize {
                            rightEdge = newRight
                            // 更新cropRect以保持同步
                            updateCropRect()
                        }
                    }
                    .onEnded { _ in
                        saveInitialRect()
                    }
            )
    }
    
    fileprivate func topLeftCornor() -> some View {
        // 左上角手柄
        Rectangle()
            .fill(Color.clear)
            .contentShape(Rectangle())
            .frame(width: handleThickness, height: handleThickness)
            .position(x: leftEdge, y: topEdge)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let newLeft = initialRect.minX + value.translation.width
                        let newTop = initialRect.minY + value.translation.height
                        // 确保不超过最小尺寸
                        if rightEdge - newLeft >= minSize {
                            leftEdge = newLeft
                        }
                        if bottomEdge - newTop >= minSize {
                            topEdge = newTop
                        }
                        // 更新cropRect以保持同步
                        updateCropRect()
                    }
                    .onEnded { _ in
                        saveInitialRect()
                    }
            )
    }
    
    fileprivate func topRightCornor() -> some View {
        // 右上角手柄
        Rectangle()
            .fill(Color.clear)
            .contentShape(Rectangle())
            .frame(width: handleThickness, height: handleThickness)
            .position(x: rightEdge, y: topEdge)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let newRight = initialRect.maxX + value.translation.width
                        let newTop = initialRect.minY + value.translation.height
                        // 确保不超过最小尺寸
                        if newRight - leftEdge >= minSize {
                            rightEdge = newRight
                        }
                        if bottomEdge - newTop >= minSize {
                            topEdge = newTop
                        }
                        // 更新cropRect以保持同步
                        updateCropRect()
                    }
                    .onEnded { _ in
                        saveInitialRect()
                    }
            )
    }
    
    fileprivate func bottomLeftCornor() -> some View {
         // 左下角手柄
        Rectangle()
            .fill(Color.clear)
            .contentShape(Rectangle())
            .frame(width: handleThickness, height: handleThickness)
            .position(x: leftEdge, y: bottomEdge)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let newLeft = initialRect.minX + value.translation.width
                        let newBottom = initialRect.maxY + value.translation.height
                        // 确保不超过最小尺寸
                        if rightEdge - newLeft >= minSize {
                            leftEdge = newLeft
                        }
                        if newBottom - topEdge >= minSize {
                            bottomEdge = newBottom
                        }
                        // 更新cropRect以保持同步
                        updateCropRect()
                    }
                    .onEnded { _ in
                        saveInitialRect()
                    }
            )
    }
    
    fileprivate func bottomRightCornor() -> some View {
        // 右下角手柄
        Rectangle()
            .fill(Color.clear)
            .contentShape(Rectangle())
            .frame(width: handleThickness, height: handleThickness)
            .position(x: rightEdge, y: bottomEdge)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let newRight = initialRect.maxX + value.translation.width
                        let newBottom = initialRect.maxY + value.translation.height
                        // 确保不超过最小尺寸
                        if newRight - leftEdge >= minSize {
                            rightEdge = newRight
                        }
                        if newBottom - topEdge >= minSize {
                            bottomEdge = newBottom
                        }
                        // 更新cropRect以保持同步
                        updateCropRect()
                    }
                    .onEnded { _ in
                        saveInitialRect()
                    }
            )
    }
    
    @State private var lastDragLocation: CGPoint?
    @State private var lastScale: CGFloat?
    
    fileprivate func centerArea() -> some View {
        Rectangle()
            .fill(Color.clear)
            .contentShape(Rectangle())
            .position(x: (leftEdge + rightEdge) / 2, y: (topEdge + bottomEdge) / 2)
            .gesture(
                SimultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            if let last = lastDragLocation {
                                let delta = CGPoint(x: value.location.x - last.x, y: value.location.y - last.y)
                                self.translation = delta
                            }
                            lastDragLocation = value.location
                        }
                        .onEnded { value in
                            lastDragLocation = nil
                        },
                    MagnificationGesture()
                        .onChanged { scale in
                            let adjustedScale = 1.0 + (scale - 1.0) * 0.5
                            self.scale = adjustedScale
                        }
                        .onEnded { _ in
                            self.scale = 1.0
                        }
                )
            )
    }
    
    fileprivate func cropArea() -> some View {
         // 黄色边框
        Rectangle()
            .stroke(Color.yellow, lineWidth: 2)
            .frame(width: rightEdge - leftEdge, height: bottomEdge - topEdge)
            .position(x: (leftEdge + rightEdge) / 2, y: (topEdge + bottomEdge) / 2)
    }
    
    var body: some View {
        ZStack {
            ZStack {
                Color.black.opacity(0.3)
                
                Rectangle()
                    .fill(Color.white)
                    .frame(width: rightEdge - leftEdge, height: bottomEdge - topEdge)
                    .position(x: (leftEdge + rightEdge) / 2, y: (topEdge + bottomEdge) / 2)
                    .blendMode(.destinationOut)
            }
            .compositingGroup()
            
            centerArea()
            
            cropArea()
                
            topline()
            
            bottomLine()
            
            leftLine()
            
            rightLine()
            
            topLeftCornor()
            
            topRightCornor()
            
            bottomLeftCornor()
            
            bottomRightCornor()

        }
        .onAppear {
            initializeEdges()
        }
        .onChange(of: cropRect) { newRect in
            if !initialized, newRect != CGRect(x: leftEdge, y: topEdge, width: rightEdge - leftEdge, height: bottomEdge - topEdge) {
                initializeEdges()
                initialized = true
            }
        }
    }
    
    private func initializeEdges() {
        leftEdge = cropRect.minX
        rightEdge = cropRect.maxX
        topEdge = cropRect.minY
        bottomEdge = cropRect.maxY
        saveInitialRect()
    }
    
    private func saveInitialRect() {
        initialRect = CGRect(x: leftEdge, y: topEdge, width: rightEdge - leftEdge, height: bottomEdge - topEdge)
    }
    
    private func updateCropRect() {
        cropRect = CGRect(x: leftEdge, y: topEdge, width: rightEdge - leftEdge, height: bottomEdge - topEdge)
    }
}
