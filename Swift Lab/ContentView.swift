//
//  ContentView.swift
//  Swift Lab
//
//  Created by Tom Hill on 21/7/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView(.vertical) {
                    
                    GeometryReader { geometry in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .global).minY)
                            .frame(height: 0)
                    }
                    
                    Spacer().frame(height: 100)
                    
                    NavigationLink(destination: HapticImageView()) {
                        NavLinkView(text: "Haptic Image")
                    }
                    NavigationLink(destination: SquareGridView()) {
                        NavLinkView(text: "Palettes")
                    }
                    NavigationLink(destination: HNView()) {
                        NavLinkView(text: "HN")
                    }
                    NavigationLink(destination: PIDView()) {
                        NavLinkView(text: "PID")
                    }
                }
                .padding()
                .ignoresSafeArea()
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    self.scrollOffset = value
                }
                
                VStack {
                    BlurView(
                        title: "Swift Etudes"
                    ).frame(height: 100)
                    Spacer()
                }.ignoresSafeArea(edges: .top)
            }
        }
    }
}

struct BlurView: View {
    var title: String
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        ZStack {
            VisualEffectBlur(blurStyle: .systemMaterial)
            Text(title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .padding(.top, 50)
        }
    }
}

struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}


struct ScrollOffsetPreferenceKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

struct NavLinkView: View {
    var background: Color = .purple
    var text: String
    
    @State private var isPressed = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(background)
                .frame(height: 100)
                .visualEffect { content, geometryProxy in
                    content.hueRotation(.degrees(
                        geometryProxy.frame(in: .global).origin.y / 10
                    ))
                }
            Text(text)
                .font(.system(size: 24, weight: .light, design: .serif))
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    ContentView()
}
