import SwiftUI

struct CropOverlayView: View {
    @Binding var cropRect: CGRect
    @Binding var scale: CGFloat
    @Binding var rotationAngle: Angle
      
    var getmaxRect: (() -> CGRect)
    var didUpdateTranslation: ((_ offset: CGPoint, _ didEnd: Bool) -> Void)?
    
    let handleThickness: CGFloat = 30
    let minSize: CGFloat = 50
    @State private var initialRect: CGRect = .zero
    @State private var topEdge: CGFloat = .zero
    @State private var bottomEdge: CGFloat = .zero
    @State private var leftEdge: CGFloat = .zero
    @State private var rightEdge: CGFloat = .zero
    @State private var initialized: Bool = false
    @State private var translationInMove: CGPoint = .zero
    @State private var initialRect0: CGRect = .zero
    
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
                        let maxRect = getmaxRect()
                        if bottomEdge - newTop >= maxRect.height {
                            topEdge = maxRect.minY
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
                        let maxRect = getmaxRect()
                        let newBottom = initialRect.maxY + value.translation.height
                        if newBottom - topEdge >= minSize, newBottom <= maxRect.maxY {
                            bottomEdge = newBottom
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
                        if rightEdge - newLeft >= minSize {
                            leftEdge = newLeft
                            updateCropRect()
                        }
                        let maxRect = getmaxRect()
                        if rightEdge - newLeft > maxRect.width {
                            leftEdge = maxRect.minX
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
                        if newRight - leftEdge >= minSize {
                            rightEdge = newRight
                            updateCropRect()
                        }
                        let maxRect = getmaxRect()
                        if newRight - leftEdge >= maxRect.width {
                            rightEdge = maxRect.maxX
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
                        if rightEdge - newLeft >= minSize {
                            leftEdge = newLeft
                        }
                        if bottomEdge - newTop >= minSize {
                            topEdge = newTop
                        }
                        let maxRect = getmaxRect()
                        if rightEdge - newLeft >= maxRect.width {
                            leftEdge = maxRect.minX
                        }
                        if bottomEdge - newTop >= maxRect.height {
                            topEdge = maxRect.minY
                        }
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
                        if  newRight - leftEdge >= minSize {
                            rightEdge = newRight
                        }
                        let maxRect = getmaxRect()
                        if newRight - leftEdge >= maxRect.width {
                            rightEdge = maxRect.maxX
                        }
                        if bottomEdge - newTop >= minSize {
                            topEdge = newTop
                        }
                        if bottomEdge - newTop >= maxRect.height {
                            topEdge = maxRect.minY
                        }
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
                        if rightEdge - newLeft >= minSize {
                            leftEdge = newLeft
                        }
                        let maxRect = getmaxRect()
                        if rightEdge - newLeft >= maxRect.width {
                            leftEdge = maxRect.minX
                        }
                        if newBottom - topEdge >= minSize {
                            bottomEdge = newBottom
                        }
                        if newBottom - topEdge > maxRect.height {
                            bottomEdge = maxRect.maxY
                        }
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
                        if newRight - leftEdge >= minSize {
                            rightEdge = newRight
                        }
                        let maxRect = getmaxRect()
                        if newRight - leftEdge > maxRect.width {
                            rightEdge = maxRect.maxX
                        }
                        if newBottom - topEdge >= minSize {
                            bottomEdge = newBottom
                        }
                        if newBottom - topEdge > maxRect.height {
                            bottomEdge = maxRect.maxY
                        }
                        updateCropRect()
                    }
                    .onEnded { _ in
                        saveInitialRect()
                        didEndDrag()
                        preRect = cropRect
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
                            guard let last = lastDragLocation else {
                                lastDragLocation = value.location
                                return
                            }
                            let delta = CGPoint(x: value.location.x - last.x, y: value.location.y - last.y)
                            didUpdateTranslation?(delta, false)
                            lastDragLocation = value.location
                        }
                        .onEnded { value in
                            didUpdateTranslation?(.zero, true)
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
            updateEdges(cropRect)
        }
        .onChange(of: cropRect) {_, newRect in
            if !initialized, newRect != CGRect(x: leftEdge, y: topEdge, width: rightEdge - leftEdge, height: bottomEdge - topEdge) {
                updateEdges(newRect)
                preRect = newRect
                initialized = true
                initialRect0 = newRect
            }
        }
    }
    
    private func updateEdges(_ rect: CGRect) {
        leftEdge = rect.minX
        rightEdge = rect.maxX
        topEdge = rect.minY
        bottomEdge = rect.maxY
        saveInitialRect()
    }
    
    private func saveInitialRect() {
        initialRect = CGRect(x: leftEdge, y: topEdge, width: rightEdge - leftEdge, height: bottomEdge - topEdge)
    }
    
    private func updateCropRect() {
        cropRect = CGRect(x: leftEdge, y: topEdge, width: rightEdge - leftEdge, height: bottomEdge - topEdge)
    }
    
    @State private var preRect: CGRect = .zero
    
    func didEndDrag() {
        let preSize = preRect.width * preRect.height
        let currentSize = cropRect.width * cropRect.height
        let scale = preSize / currentSize
        let translation = CGPoint(x: -(preRect.midX - cropRect.midX), y: -(preRect.midY - cropRect.midY))
//        self.scale = scale
//        didUpdateTranslation?(translation, true)
       
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            let cropAspect = cropRect.width / cropRect.height
            let initialAspect = initialRect0.width / initialRect0.height
            if cropAspect > initialAspect {
                let width = initialRect0.width
                let height = width / cropAspect
                updateEdges(CGRect(x: initialRect0.midX - width * 0.5, y: initialRect0.midY - height * 0.5, width: width, height: height))
            } else {
                let height = initialRect0.height
                let width = height * cropAspect
                updateEdges(CGRect(x: initialRect0.midX - width * 0.5, y: initialRect0.midY - height * 0.5, width: width, height: height))
            }
            
            print("initialRect0:\(initialRect0) - cropRect:\(cropRect)")
        })
    }
}
