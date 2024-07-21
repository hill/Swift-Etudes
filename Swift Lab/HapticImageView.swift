//
//  HapticImage.swift
//  Swift Lab
//
//  Created by Tom Hill on 21/7/2024.
//

import SwiftUI

struct HapticImageView: View {
    
    @State private var isPressed = false
    
    var body: some View {
        VStack {
            Spacer()
            Image("img")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.blue, lineWidth: 8)
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.spring(response: 0.15), value: isPressed)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if !isPressed {
                                isPressed = true
                                hapticFeedback()
                            }
                        }
                        .onEnded { _ in isPressed = false }
                )
            Spacer()
        }
        .padding()
    }
    
    private func hapticFeedback() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
}

#Preview {
    HapticImageView()
}
