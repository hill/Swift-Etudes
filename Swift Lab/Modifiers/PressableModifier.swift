//
//  PressableModifier.swift
//  Swift Lab
//
//  Created by Tom Hill on 21/7/2024.
//

import SwiftUI

struct PressableModifier: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.15), value: isPressed)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                        }
                    }
                    .onEnded { _ in isPressed = false }
            )
    }
}

extension View {
    func pressable() -> some View {
        self.modifier(PressableModifier())
    }
}
