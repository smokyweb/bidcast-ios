//
//  ShimmerViewModifier.swift
//  BidCast
//
//  Created by Vivek-JAM_E-328 on 14/10/25.
//

import SwiftUI

struct ShimmerViewModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        gradient: Gradient(colors: [.gray, .lightText.opacity(0.6), .ghostWhite]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(width: geometry.size.width * 3, height: geometry.size.height)
                    .offset(x: -geometry.size.width * 2 + phase * geometry.size.width * 3)
                    .blendMode(.plusLighter)
                }
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
