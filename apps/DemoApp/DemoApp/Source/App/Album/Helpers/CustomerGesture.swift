//
//  CustomerGesture.swift
//  App
//
//  Created by Renjun Li on 2024/8/16.
//

import SwiftUI

struct CustomerGesture: UIGestureRecognizerRepresentable {
    var isEnabled: Bool
    var handle: (UIPanGestureRecognizer) -> ()
    
    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
        Coordinator()
    }
    
    func makeUIGestureRecognizer(context: Context) -> UIPanGestureRecognizer {
        let ges = UIPanGestureRecognizer()
        ges.delegate = context.coordinator
        return ges
    }
    
    func updateUIGestureRecognizer(_ recognizer: UIPanGestureRecognizer, context: Context) {
        recognizer.isEnabled = isEnabled
    }
    
    func handleUIGestureRecognizerAction(_ recognizer: UIPanGestureRecognizer, context: Context) {
        handle(recognizer)
    }
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
    }
    
}
