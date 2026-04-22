//
//  ShimmerEffectView.swift
//  BidCast
//
//  Created by JamTech on 15/11/25.
//

import SwiftUI

struct CategoryCardFullShimmerView: View {
    var width: CGFloat = 110
    var height: CGFloat = 170
    var backgroundColor: Color = Color.gray.opacity(0.1)
    var cornerRadius: CGFloat = 14
    var body: some View {
        PulseShimmerView()
            .frame(width: width, height: height)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

struct ShimmerEffectView: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.1))
            .mask(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.7),
                        Color.black.opacity(0.3),
                        Color.black.opacity(0.7)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .rotationEffect(.degrees(0))
                .offset(x: phase)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                    phase = 250
                }
            }
    }
}

struct PulseShimmerView: View {
    @State private var opacity: Double = 0.1

    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.1))
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 1.0)
                        .repeatForever(autoreverses: true)
                ) {
                    opacity = 0.7
                }
            }
    }
}
