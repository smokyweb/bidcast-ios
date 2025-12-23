import SwiftUI

@available(macOS 11.0, *)
@available(iOS 14.0, *)
public struct FortuneWheel: View {

    private var titles: [String], size: CGFloat, onSpinEnd: ((Int) -> ())?, strokeWidth: CGFloat, strokeColor: Color = .defaultTheme.opacity(0.7)
    private var colors: [Color] = Color.spin_wheel_color, pointerColor: Color = Color(hex: "DA4533")
    @StateObject var viewModel: FortuneWheelViewModel
    
    public init(
        titles: [String], size: CGFloat, onSpinEnd: ((Int) -> ())?,
        colors: [Color]? = nil, pointerColor: Color? = nil,
        strokeWidth: CGFloat = 8, strokeColor: Color? = nil,
        animDuration: Double = Double(2),
        animation: Animation? = nil,
        getWheelItemIndex: (() -> (Int))? = nil
    ) {
        self.titles = titles
        self.size = size
        self.strokeWidth = strokeWidth
        
        if let colors = colors { self.colors = colors }
        if let pointerColor = pointerColor { self.pointerColor = pointerColor }
        if let strokeColor = strokeColor { self.strokeColor = strokeColor }
        
        let timeCurveAnimation = Animation.timingCurve(0.51, 0.97, 0.56, 0.99, duration: animDuration)
        _viewModel = StateObject(wrappedValue: FortuneWheelViewModel(
            titles: titles,
            animDuration: animDuration,
            animation: animation ?? timeCurveAnimation,
            onSpinEnd: onSpinEnd,
            getWheelItemIndex: getWheelItemIndex
        ))
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            ZStack(alignment: .center) {
                SpinWheelView(data: (0..<titles.count).map { _ in Double(100/titles.count) },
                              labels: titles, colors: colors)
                    .frame(width: size, height: size)
                    .overlay(
                        RoundedRectangle(cornerRadius: size/2).stroke(lineWidth: strokeWidth)
                            .foregroundColor(strokeColor)
                    )
                    .rotationEffect(.degrees(viewModel.degree))
                SpinWheelBolt()
            }
            SpinWheelPointer(pointerColor: pointerColor).offset(x: 0, y: -25)
        }
        .onAppear {
            viewModel.setupNotificationObserver()
        }
        .onDisappear {
            viewModel.removeNotificationObserver()
        }
    }
}

@available(macOS 10.15, *)
@available(iOS 13.0, *)
extension Color {
    static let spin_wheel_color: [Color] = [
        Color(hex: "FBE488"),
        Color(hex: "75AB53"),
        Color(hex: "D1DC59"),
        Color(hex: "EC9D42"),
        Color(hex: "DE6037"),
        Color(hex: "DA4533"),
        Color(hex: "992C4D"),
        Color(hex: "433589"),
        Color(hex: "4660A8"),
        Color(hex: "4291C8")
    ]
    
    init(hex: String, alpha: Double = 1) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if (cString.hasPrefix("#")) { cString.remove(at: cString.startIndex) }
        
        let scanner = Scanner(string: cString)
        scanner.currentIndex = scanner.string.startIndex
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        self.init(.sRGB, red: Double(r) / 0xff, green: Double(g) / 0xff, blue:  Double(b) / 0xff, opacity: alpha)
    }
}

@available(macOS 10.15, *)
@available(iOS 13.0, *)
class FortuneWheelViewModel: ObservableObject {
    
    private var titles: [String]
    
    @Published var degree = 0.0
    private let animDuration: Double
    private var animation: Animation
    private var pendingRequestWorkItem: DispatchWorkItem?
    private var notificationObserver: NSObjectProtocol?
    
    private var onSpinEnd: ((Int) -> ())?, getWheelItemIndex: (() -> (Int))?
    
    init(
        titles: [String], animDuration: Double, animation: Animation,
        onSpinEnd: ((Int) -> ())?, getWheelItemIndex: (() -> (Int))?
    ) {
        self.titles = titles
        self.animDuration = animDuration
        self.animation = animation
        self.onSpinEnd = onSpinEnd
        self.getWheelItemIndex = getWheelItemIndex
    }
    
    func setupNotificationObserver() {
        notificationObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("SpinWheel"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.spinWheel()
        }
    }
    
    func removeNotificationObserver() {
        if let observer = notificationObserver {
            NotificationCenter.default.removeObserver(observer)
            notificationObserver = nil
        }
    }

    private func getWheelStopDegree() -> Double {
        var index = -1
        if let method = getWheelItemIndex { index = method() }
        if index < 0 || index >= titles.count { index = Int.random(in: 0..<titles.count) }
        index = titles.count - index - 1
        
        let itemRange = 360 / titles.count
        let indexDegree = itemRange * index
        let freeRange = Int.random(in: 0...itemRange)
        let freeSpins = (2...20).map({ return $0 * 360 }).randomElement()!
        let finalDegree = freeSpins + indexDegree + freeRange
        return Double(finalDegree)
    }
    
    func spinWheel() {
        withAnimation(animation) {
            self.degree = Double(360 * Int(self.degree / 360)) + getWheelStopDegree()
        }
        
        // Cancel the currently pending item
        pendingRequestWorkItem?.cancel()
        
        // Wrap our request in a work item
        let requestWorkItem = DispatchWorkItem { [weak self] in
            if let count = self?.titles.count,
               let distance = self?.degree.truncatingRemainder(dividingBy: 360) {
                let pointer = floor(distance/(360/Double(count)))
                if let onSpinEnd = self?.onSpinEnd {
                    onSpinEnd(count - Int(pointer) - 1)
                }
            }
        }
        
        // Save the new work item and execute it after duration
        pendingRequestWorkItem = requestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + animDuration + 1, execute: requestWorkItem)
    }
}

@available(macOS 10.15, *)
@available(iOS 13.0, *)
struct Triangle: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addCurve(to: CGPoint(x: rect.midX, y: rect.minY), control1: CGPoint(x: rect.maxX, y: rect.minY), control2: CGPoint(x: rect.midX, y: rect.minY))
        return path
    }
}

@available(macOS 10.15, *)
@available(iOS 13.0, *)
struct SpinWheelPointer: View {
    var pointerColor: Color
    var body: some View {
        Triangle().frame(width: 50, height: 50)
            .foregroundColor(pointerColor).cornerRadius(24)
            .rotationEffect(.init(degrees: 180))
            .shadow(color: Color(hex: "212121", alpha: 0.5), radius: 5, x: 0.0, y: 1.0)
    }
}

@available(macOS 10.15, *)
@available(iOS 13.0, *)
struct SpinWheelBolt: View {
    var body: some View {
        ZStack {
            Circle().frame(width: 28, height: 28)
                .foregroundColor(Color(hex: "F4C25B"))
            Circle().frame(width: 18, height: 18)
                .foregroundColor(Color(hex: "FFD25A"))
                .shadow(color: Color(hex: "404040", alpha: 0.35), radius: 3, x: 0.0, y: 1.0)
        }
    }
}

@available(macOS 10.15, *)
@available(iOS 13.0, *)
struct SpinWheelView: View {
    
    var data: [Double], labels: [String]
    
    private let colors: [Color]
    private let sliceOffset: Double = -.pi / 2
    
    init(data: [Double], labels: [String], colors: [Color]) {
        self.data = data
        self.labels = labels
        self.colors = colors
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .center) {
                ForEach(0..<data.count, id: \.self) { index in
                    SpinWheelCell(startAngle: startAngle(for: index), endAngle: endAngle(for: index))
                        .fill(colors[index % colors.count])
                    Text(labels[index]).foregroundColor(Color.white).fontWeight(.bold)
                        .offset(viewOffset(for: index, in: geo.size)).zIndex(1)
                }
            }
        }
    }
    
    private func startAngle(for index: Int) -> Double {
        switch index {
        case 0: return sliceOffset
        default:
            let ratio: Double = data[..<index].reduce(0.0, +) / data.reduce(0.0, +)
            return sliceOffset + 2 * .pi * ratio
        }
    }
    
    private func endAngle(for index: Int) -> Double {
        switch index {
        case data.count - 1: return sliceOffset + 2 * .pi
        default:
            let ratio: Double = data[..<(index + 1)].reduce(0.0, +) / data.reduce(0.0, +)
            return sliceOffset + 2 * .pi * ratio
        }
    }
    
    private func viewOffset(for index: Int, in size: CGSize) -> CGSize {
        let radius = min(size.width, size.height) / 3
        let dataRatio = (2 * data[..<index].reduce(0, +) + data[index]) / (2 * data.reduce(0, +))
        let angle = CGFloat(sliceOffset + 2 * .pi * dataRatio)
        return CGSize(width: radius * cos(angle), height: radius * sin(angle))
    }
}

@available(macOS 10.15, *)
@available(iOS 13.0, *)
struct SpinWheelCell: Shape {
    
    let startAngle: Double, endAngle: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = min(rect.width, rect.height) / 2
        let alpha = CGFloat(startAngle)
        let center = CGPoint(
            x: rect.midX,
            y: rect.midY
        )
        path.move(to: center)
        path.addLine(
            to: CGPoint(
                x: center.x + cos(alpha) * radius,
                y: center.y + sin(alpha) * radius
            )
        )
        path.addArc(
            center: center, radius: radius,
            startAngle: Angle(radians: startAngle),
            endAngle: Angle(radians: endAngle),
            clockwise: false
        )
        path.closeSubpath()
        return path
    }
}
