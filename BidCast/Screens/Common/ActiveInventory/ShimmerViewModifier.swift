//
//  ShimmerViewModifier.swift
//  BidCast
//
//  Created by JamTech on 14/10/25.
//

import SwiftUI

struct ShimmerViewModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(gradient: Gradient(colors: [.clear, Color.white.opacity(0.4), .clear]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .rotationEffect(.degrees(30))
                    .offset(x: phase * 200, y: phase * 200)
                    .blendMode(.plusLighter)
            )
            .mask(content)
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerViewModifier())
    }
}
