//
//  ContentView.swift
//  Drawing
//
//  Created by Parth Antala on 2023-02-13.
//

import SwiftUI

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        
        return path
    }

}

struct Arc: InsettableShape {
    let startAngle: Angle
    let endAngle: Angle
    let clockwise : Bool
    var insetAmount = 0.0
    
    func path(in rect: CGRect) -> Path {
        
        let modifiedAngle = Angle.degrees(90)
        
        let modifiedStartAngle = startAngle - modifiedAngle
        let modifiedEndAngle = endAngle - modifiedAngle
        
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2 - insetAmount, startAngle: modifiedStartAngle, endAngle: modifiedEndAngle, clockwise: !clockwise)
        
        return path
    }
    
    func inset(by amount: CGFloat) -> some InsettableShape {
        var arc = self
        arc.insetAmount += amount
        return arc
    }
    
}

struct Flower: Shape {
    var petalOffset = -20.0
    var petalWidth = 100.0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        for number in stride(from: 0, to: Double.pi * 2, by: Double.pi / 8) {
            let rotation = CGAffineTransform(rotationAngle: number)
            let postiion = rotation.concatenating(CGAffineTransform(translationX: rect.width / 2, y: rect.height / 2))
            let originalPetal = Path(ellipseIn: CGRect(x: petalOffset, y: 0, width: petalWidth, height: rect.height / 2 ))
            
            let rotatedPetal = originalPetal.applying(postiion)
            
            path.addPath(rotatedPetal)
        }
        
        return path
    }
}

struct ColorCyclingCirle: View {
    var amount = 0.0
    var steps = 100
    
    var body: some View {
        ZStack {
            ForEach(0..<steps) { value in
                Circle()
                    .inset(by: Double(value))
                    .strokeBorder(color(for: value, brightness: 1), lineWidth: 2)
            }
        }
    }
    
    func color(for value: Int, brightness: Double) -> Color {
        var targetHue = Double(value) / Double(steps) + amount
        
        if targetHue > 1 {
            targetHue -= 1
        }
        
        return Color(hue: targetHue, saturation: 1, brightness: brightness)
    }
}

struct Trapezoid: Shape {
    var insetAmount: Double
    
    var animatableData: Double {
        get { insetAmount }
        set { insetAmount = newValue }
    }
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.maxY))
        path.addLine(to: CGPoint(x: insetAmount, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - insetAmount, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        
        return path
    }
}

struct checkerbox: Shape {
    var rows: Int
    var columns: Int
    
    var animatableData: AnimatablePair<Double, Double> {
        get {
            AnimatablePair(Double(rows), Double(columns))
        }
        
        set {
            rows = Int(newValue.first)
            columns = Int(newValue.second)
        }
    }
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let rowSize = rect.height / Double(rows)
        let columnSize = rect.width / Double(columns)
        
        for row in 0..<rows {
            for column in 0..<columns {
                if (row + column).isMultiple(of: 2) {
                    let startX = columnSize * Double(column)
                    let startY = rowSize * Double(row)
                    
                    let rect = CGRect(x: startX, y: startY, width: columnSize, height: rowSize)
                    path.addRect(rect)
                }
            }
        }
        return path
    }
}
struct ContentView: View {
    
    @State private var petalOffset = -20.0
    @State private var petalWidth = 100.0
    @State private var colorCycle = 0.0
    
    @State private var amount = 0.0
    @State private var insetAmount = 50.0
    
    @State private var rows = 4
    @State private var columns = 4
    
    var body: some View {
        List {
            VStack {
                checkerbox(rows: rows, columns: columns)
                    .onTapGesture {
                        withAnimation(.linear(duration: 3)) {
                            rows = Int.random(in: 3...8)
                            columns = Int.random(in: 3...8)
                        }
                    }
            }
            .frame(width: 300, height: 300)
            VStack{
            Trapezoid(insetAmount: insetAmount)
                    .frame(width: 300, height: 300)
                    .onTapGesture {
                        withAnimation{
                            insetAmount = Double.random(in: 10...90)
                        }
                    }
            }
            VStack{
                ZStack{
                    Circle()
                        .fill(Color(red: 1, green: 0, blue: 0))
                        .frame(width: 200 * amount)
                        .offset(x: -50, y: -80)
                        .blendMode(.screen)
                    
                    Circle()
                        .fill(Color(red: 0, green: 1, blue: 0))
                        .frame(width: 200 * amount)
                        .offset(x: 50, y: -80)
                        .blendMode(.screen)
                    
                    Circle()
                        .fill(Color(red: 0, green: 0, blue: 1))
                        .frame(width: 200 * amount)
                        .blendMode(.screen)
                }
                .frame(width: 300, height: 300)
                
                Slider(value: $amount)
                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black)
            .ignoresSafeArea()
            
            
            VStack{
                ColorCyclingCirle(amount: colorCycle)
                    .frame(width: 300, height: 300)
                
                Slider(value: $colorCycle)
            }
            
            
            VStack{
                Spacer()
                Flower(petalOffset: petalOffset, petalWidth: petalWidth)
                    .fill(.blue, style: FillStyle(eoFill: true))
                    .frame(width: 300, height: 300)
                Spacer()
                Text("Offset \(petalOffset.formatted())")
                Slider(value: $petalOffset, in: -40...40)
                    .padding([.horizontal,.bottom])
                
                Text("Width")
                Slider(value: $petalWidth, in: 0...100)
                    .padding([.horizontal])
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
