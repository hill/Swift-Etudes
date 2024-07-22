//
//  SquareGridView.swift
//  Swift Lab
//
//  Created by Tom Hill on 22/7/2024.
//

import SwiftUI

struct SquareGridView: View {

    @State private var selectedRect: (Int, Int)? = nil
    @State private var startingColor: Color = Color.orange
    @Namespace private var namespace
    
    var body: some View {
        
        let animation = Animation.snappy(duration: 0.1)
        
        ZStack {
            if let selected = selectedRect {
                let degrees = selected.0 * 40 + selected.1 * 10
                let sampledColor = colorWithAdjustedHue(color: startingColor, angle: Double(degrees))
                
                VStack {
                    rotatedRectangle(degrees: degrees)
                        .matchedGeometryEffect(id: "\(selected.0)-\(selected.1)", in: namespace)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(animation) {
                                selectedRect = nil
                            }
                        }
                        .navigationBarBackButtonHidden(true)
                    
                    Text(hexString(from: sampledColor))
                        .font(.largeTitle)
                        .bold()
                        .monospaced()
                        .foregroundStyle(Color(sampledColor))
                        .padding()
                }
            } else {
                ZStack {
                    VStack {
                        Text("Rotated Rectangle Study").font(.title2).bold()
                        ForEach(0..<5) { i in
                            HStack {
                                ForEach(0..<3) { j in
                                    rotatedRectangle(degrees: i*40 + j*10)
                                        .matchedGeometryEffect(id: "\(i)-\(j)", in: namespace)
                                        .onTapGesture {
                                            withAnimation(animation) {
                                                selectedRect = (i,j)
                                            }
                                        }
                                }
                            }.padding(.horizontal, 15)
                            
                        }
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    
                    randomPalletteButton()
                    
                }
            }
        }.onAppear {
            rollColor()
        }
    };
    
    func rollColor() {
        startingColor = Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }
    
    func rotatedRectangle(degrees: Int) -> some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(startingColor)
            .hueRotation(Angle(degrees: Double(degrees)))
    }
    
    func randomPalletteButton() -> some View {
        VStack {
            Spacer()
            Button(action: rollColor) {
                Image(systemName: "dice")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding()
                    .background(Color.white)
                    .clipShape(Capsule())
                    .shadow(radius: 5)
            }
            .padding(.bottom, 10)
        }
    }
    
    func colorWithAdjustedHue(color: Color, angle: Double) -> Color {
            let uiColor = UIColor(color)
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            
            hue += CGFloat(angle / 360.0)
            if hue > 1.0 { hue -= 1.0 }
            if hue < 0.0 { hue += 1.0 }
            
            return Color(hue: Double(hue), saturation: Double(saturation), brightness: Double(brightness), opacity: Double(alpha))
        }
        
        func hexString(from color: Color) -> String {
            let uiColor = UIColor(color)
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            return String(format: "#%02lX%02lX%02lX", lroundf(Float(red * 255)), lroundf(Float(green * 255)), lroundf(Float(blue * 255)))
        }
}

#Preview {
    SquareGridView()
}
