//
//  File.swift
//  AINote
//
//  Created by Renjun Li on 2024/11/28.
//

import SwiftUI

struct PopupContentView: View {
    var body: some View {
        VStack {
            Text("Hello, SwiftUI Window!")
                .font(.headline)
                .padding()
            Button("Close") {
                NSApplication.shared.keyWindow?.close()
            }
            .padding()
        }
        .background(.white)
        .frame(width: 300, height: 200)
    }
}


protocol Shape {
    func draw() -> String
}

struct Triangle: Shape {
    var size: Int
    func draw() -> String {
       var result: [String] = []
       for length in 1...size {
           result.append(String(repeating: "*", count: length))
       }
       return result.joined(separator: "\n")
    }
}
let smallTriangle = Triangle(size: 3)


struct FlippedShape<T: Shape>: Shape {
    var shape: T
    func draw() -> String {
        let lines = shape.draw().split(separator: "\n")
        return lines.reversed().joined(separator: "\n")
    }
}
let flippedTriangle = FlippedShape(shape: smallTriangle)


struct JoinedShape<T: Shape, U: Shape>: Shape {
    var top: T
    var bottom: U
    func draw() -> String {
       return top.draw() + "\n" + bottom.draw()
    }
}
let joinedTriangles = JoinedShape(top: smallTriangle, bottom: flippedTriangle)


struct Square: Shape {
    var size: Int
    func draw() -> String {
        let line = String(repeating: "*", count: size)
        let result = Array<String>(repeating: line, count: size)
        return result.joined(separator: "\n")
    }
}

func makeTrapezoid() -> some Shape {
    let top = Triangle(size: 2)
    let middle = Square(size: 2)
    let bottom = FlippedShape(shape: top)
    let trapezoid = JoinedShape(
        top: top,
        bottom: JoinedShape(top: middle, bottom: bottom)
    )
    return trapezoid
}

func makeTrapezoid1() -> Shape {
    let top = Triangle(size: 2)
    let middle = Square(size: 2)
    let bottom = FlippedShape(shape: top)
    let trapezoid = JoinedShape(
        top: top,
        bottom: JoinedShape(top: middle, bottom: bottom)
    )
    return trapezoid
}


let trape = makeTrapezoid()  as! JoinedShape<Triangle, FlippedShape<Triangle>>
let trape1 = makeTrapezoid1() as! JoinedShape<Triangle, FlippedShape<Triangle>>

struct Circle: Shape {
    func draw() -> String {
        return "Drawing a circle"
    }
}

struct Rectangle: Shape {
    func draw() -> String {
        return "Drawing a rectangle"
    }
}

// 错误：协议 'Shape' 不能直接用作类型，因为它没有类型擦除
let shapeArray: [Shape] = [Circle(), Rectangle()]

let shapeArray1: [any Shape] = [Circle(), Rectangle()]
