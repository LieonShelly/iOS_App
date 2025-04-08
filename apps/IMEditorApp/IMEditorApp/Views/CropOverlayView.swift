import SwiftUI

struct CropOverlayView: View {
    @Binding var cropRect: CGRect
    let handleThickness: CGFloat = 30
    let minSize: CGFloat = 50
    @State private var initialRect: CGRect = .zero

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .stroke(Color.yellow, lineWidth: 2)
                    .frame(width: cropRect.width, height: cropRect.height)
                    .position(x: cropRect.midX, y: cropRect.midY)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                cropRect.origin.x = initialRect.origin.x + value.translation.width
                                cropRect.origin.y = initialRect.origin.y + value.translation.height
                            }
                            .onEnded { _ in
                                initialRect = cropRect
                            }
                    )
                    .onAppear {
                        initialRect = cropRect
                    }

                edgeHandle(position: CGPoint(x: cropRect.midX, y: cropRect.minY)) { value in
                    let newY = initialRect.origin.y + value.translation.height
                    let delta = initialRect.origin.y - newY
                    let newHeight = initialRect.height + delta
                    if newHeight >= minSize {
                        cropRect.origin.y = newY
                        cropRect.size.height = newHeight
                    }
                }

                edgeHandle(position: CGPoint(x: cropRect.midX, y: cropRect.maxY)) { value in
                    let newHeight = initialRect.height + value.translation.height
                    if newHeight >= minSize {
                        cropRect.size.height = newHeight
                    }
                }

                edgeHandle(position: CGPoint(x: cropRect.minX, y: cropRect.midY), vertical: true) { value in
                    let newX = initialRect.origin.x + value.translation.width
                    let delta = initialRect.origin.x - newX
                    let newWidth = initialRect.width + delta
                    if newWidth >= minSize {
                        cropRect.origin.x = newX
                        cropRect.size.width = newWidth
                    }
                }

                edgeHandle(position: CGPoint(x: cropRect.maxX, y: cropRect.midY), vertical: true) { value in
                    let newWidth = initialRect.width + value.translation.width
                    if newWidth >= minSize {
                        cropRect.size.width = newWidth
                    }
                }

                cornerHandle(position: cropRect.origin) { value in
                    let newX = initialRect.origin.x + value.translation.width
                    let newY = initialRect.origin.y + value.translation.height
                    let deltaX = initialRect.origin.x - newX
                    let deltaY = initialRect.origin.y - newY
                    let newWidth = initialRect.width + deltaX
                    let newHeight = initialRect.height + deltaY

                    if newWidth >= minSize {
                        cropRect.origin.x = newX
                        cropRect.size.width = newWidth
                    }
                    if newHeight >= minSize {
                        cropRect.origin.y = newY
                        cropRect.size.height = newHeight
                    }
                }

                cornerHandle(position: CGPoint(x: cropRect.maxX, y: cropRect.minY)) { value in
                    let newY = initialRect.origin.y + value.translation.height
                    let deltaY = initialRect.origin.y - newY
                    let newHeight = initialRect.height + deltaY
                    let newWidth = initialRect.width + value.translation.width

                    if newHeight >= minSize {
                        cropRect.origin.y = newY
                        cropRect.size.height = newHeight
                    }
                    if newWidth >= minSize {
                        cropRect.size.width = newWidth
                    }
                }

                cornerHandle(position: CGPoint(x: cropRect.minX, y: cropRect.maxY)) { value in
                    let newX = initialRect.origin.x + value.translation.width
                    let deltaX = initialRect.origin.x - newX
                    let newWidth = initialRect.width + deltaX
                    let newHeight = initialRect.height + value.translation.height

                    if newWidth >= minSize {
                        cropRect.origin.x = newX
                        cropRect.size.width = newWidth
                    }
                    if newHeight >= minSize {
                        cropRect.size.height = newHeight
                    }
                }

                cornerHandle(position: CGPoint(x: cropRect.maxX, y: cropRect.maxY)) { value in
                    let newWidth = initialRect.width + value.translation.width
                    let newHeight = initialRect.height + value.translation.height

                    if newWidth >= minSize {
                        cropRect.size.width = newWidth
                    }
                    if newHeight >= minSize {
                        cropRect.size.height = newHeight
                    }
                }
                
                
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .frame(width: cropRect.width - handleThickness, height: cropRect.height - handleThickness)
                    .position(x: cropRect.midX, y: cropRect.midY)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newX = initialRect.origin.x + value.translation.width
                                let newY = initialRect.origin.y + value.translation.height
                                cropRect.origin = CGPoint(x: newX, y: newY)
                            }
                            .onEnded { _ in
                                initialRect = cropRect
                            }
                    )

            }
        }
    }

    
    func edgeHandle(position: CGPoint, vertical: Bool = false, onDrag: @escaping (DragGesture.Value) -> Void) -> some View {
        Rectangle()
            .fill(Color.clear)
            .contentShape(Rectangle())
            .frame(width: vertical ? handleThickness : cropRect.width,
                   height: vertical ? cropRect.height : handleThickness)
            .position(position)
            .gesture(
                DragGesture()
                    .onChanged { value in onDrag(value) }
                    .onEnded { _ in initialRect = cropRect }
            )
    }
    
    func cornerHandle(position: CGPoint, dragAction: @escaping (DragGesture.Value) -> Void) -> some View {
        Rectangle()
            .fill(Color.clear)
            .contentShape(Rectangle())
            .frame(width: handleThickness, height: handleThickness)
            .position(position)
            .gesture(
                DragGesture()
                    .onChanged { dragAction($0) }
                    .onEnded { _ in initialRect = cropRect }
            )
    }

}
