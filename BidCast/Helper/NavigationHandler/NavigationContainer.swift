//
//  NavigationContainer.swift
// BidSwipe
//
//  Created by JAM-E-282 on 19/01/24.
//

import SwiftUI

struct NavigationContainer<Content: View>: View {
    
    @EnvironmentObject private var appRootManager: AppRootManager
    
    let content: Content
    
    @State var route: [String] = []
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        NavigationView {
            content
                .navigationBarTitle("")
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)
                .navigationViewStyle(.stack)
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .navigationViewStyle(.stack)
    }
}


extension UINavigationController: UIGestureRecognizerDelegate {
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        return false
    }
}

public extension View {
    func onFirstAppear(perform action: @escaping () -> Void) -> some View {
        modifier(ViewFirstAppearModifier(perform: action))
    }
    
    func custCornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners) )
    }
    
    @ViewBuilder func unredacted(when condition: Binding<Bool>) -> some View {
        if condition.wrappedValue {
            redacted(reason: .placeholder)
        } else {
            unredacted()
        }
    }
    
    func rippleEffect(rippleColor: Color = .accentColor.opacity(0.5)) -> some View {
        modifier(Ripple(rippleColor: rippleColor))
    }
}

struct RoundedCorner: Shape {
    
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct ViewFirstAppearModifier: ViewModifier {
    @State private var didAppearBefore = false
    private let action: () -> Void
    
    init(perform action: @escaping () -> Void) {
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content.onAppear {
            guard !didAppearBefore else { return }
            didAppearBefore = true
            action()
        }
    }
}

    // MARK: - Ripple

struct Ripple: ViewModifier {
        // MARK: Lifecycle
    
    init(rippleColor: Color) {
        self.color = rippleColor
    }
    
        // MARK: Internal
    
    let color: Color
    
    @State private var scale: CGFloat = 0.5
    
    @State private var animationPosition: CGFloat = 0.0
    @State private var x: CGFloat = 0.0
    @State private var y: CGFloat = 0.0
    
    @State private var opacityFraction: CGFloat = 0.0
    @State private var viewSize: CGSize = .zero
    
    let timeInterval: TimeInterval = 0.5
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(.clear.opacity(0.05))
                Circle()
                    .foregroundColor(color)
                    .opacity(0.2*opacityFraction)
                    .scaleEffect(scale)
                    .offset(x: x, y: y)
                content
            }
            .onTapGesture(perform: { location in
                x = location.x-geometry.size.width/2
                y = location.y-geometry.size.height/2
                opacityFraction = 1.0
                withAnimation(.linear(duration: timeInterval)) {
                    scale = 3.0*(max(geometry.size.height, geometry.size.width)/min(geometry.size.height, geometry.size.width))
                    opacityFraction = 0.0
                    DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) {
                        scale = 1.0
                        opacityFraction = 0.0
                    }
                }
            })
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }
}
