import SwiftUI

@available(macOS 11.0, *)
@available(iOS 14.0, *)
public struct FortuneWheel: View {
    @Binding private var titles: [String]
    @Binding var spinTrigger: Bool
    private var size: CGFloat, onSpinEnd: ((Int) -> ())?, strokeWidth: CGFloat, strokeColor: Color = .defaultThemeLight
    private var colors: [Color], pointerColor: Color = Color(hex: "DA4533")
    
    @StateObject var viewModel: FortuneWheelViewModel
    
    public init(
        titles: Binding<[String]>, spinTrigger : Binding<Bool>,size: CGFloat, onSpinEnd: ((Int) -> ())?,
            colors: [Color]? = nil, pointerColor: Color? = nil,
            strokeWidth: CGFloat = 8, strokeColor: Color? = nil,
            animDuration: Double = Double(2),
            animation: Animation? = nil,
            getWheelItemIndex: (() -> (Int))? = nil,
            
        ) {
            self._titles = titles
            self._spinTrigger = spinTrigger
            self.size = size
            self.strokeWidth = strokeWidth
           
            
            // Keep colors consistent - NO shuffling
            if let colors = colors {
                self.colors = colors
            } else {
                let baseColors = Color.spin_wheel_color // Don't shuffle
                var allColors: [Color] = []
                
                // Keep adding colors in the same order until we have enough
                while allColors.count < titles.count {
                    allColors.append(contentsOf: baseColors)
                }
                
                // Take exactly the number we need
                self.colors = Array(allColors.prefix(titles.count))
            }
            
            if let pointerColor = pointerColor { self.pointerColor = pointerColor }
            if let strokeColor = strokeColor { self.strokeColor = strokeColor }
            
            let timeCurveAnimation = Animation.timingCurve(0.51, 0.97, 0.56, 0.99, duration: animDuration)
            _viewModel = StateObject(wrappedValue: FortuneWheelViewModel(
                animDuration: animDuration,
                animation: animation ?? timeCurveAnimation,
                onSpinEnd: onSpinEnd,
                getWheelItemIndex: getWheelItemIndex,
               
            ))
        }
    
    public var body: some View {
        ZStack(alignment: .top) {
            
            ZStack(alignment: .center) {
                SpinWheelView(data: (0..<titles.count).map { _ in Double(100/titles.count) },
                              labels: titles, colors: colors)
                    .frame(width: size, height: size)
                    .rotationEffect(.degrees(viewModel.degree))
                SpinWheelBolt()
            }
            SpinWheelPointer(pointerColor: pointerColor).offset(x: 0, y: 0)
        }
//        .onAppear {
//            viewModel.setupNotificationObserver()
//        }
//        .onDisappear {
//            viewModel.removeNotificationObserver()
//        }
        .onAppear {
            viewModel.updateTitles(titles)
        }
        .onChange(of: titles) { newTitles in
            viewModel.updateTitles(newTitles)
        }
        .onChange(of: spinTrigger) { newValue in
            guard newValue else { return }

            guard !titles.isEmpty else {
                print("❌ Spin ignored: titles not ready")
                spinTrigger = false
                return
            }

            viewModel.spinWheel {
                    print("✅ Spin completed — resetting trigger")
                    spinTrigger = false
                }
            
        }
    }
}

@available(macOS 10.15, *)
@available(iOS 13.0, *)
extension Color {
    static let spin_wheel_color: [Color] = [
        Color(hex: "FBE488"),  // Yellow
        Color(hex: "75AB53"),  // Green
        Color(hex: "D1DC59"),  // Lime
        Color(hex: "EC9D42"),  // Orange
        Color(hex: "DE6037"),  // Dark Orange
        Color(hex: "DA4533"),  // Red
        Color(hex: "992C4D"),  // Maroon
        Color(hex: "433589"),  // Purple
        Color(hex: "4660A8"),  // Blue
        Color(hex: "4291C8"),  // Light Blue
        
        Color(hex: "FF6B9D"),  // Pink
        Color(hex: "C44569"),  // Rose
        Color(hex: "F8B500"),  // Amber
        Color(hex: "00D2FF"),  // Cyan
        Color(hex: "3742FA"),  // Indigo
        Color(hex: "2ED573"),  // Mint
        Color(hex: "FF4757"),  // Coral
        Color(hex: "5F27CD"),  // Violet
        Color(hex: "00D8D6"),  // Turquoise
        Color(hex: "FF6348"),  // Tomato
        
        Color(hex: "A29BFE"),  // Lavender
        Color(hex: "FD79A8"),  // Carnation
        Color(hex: "FDCB6E"),  // Mustard
        Color(hex: "6C5CE7"),  // Wisteria
        Color(hex: "00B894"),  // Emerald
        Color(hex: "E17055"),  // Terracotta
        Color(hex: "0984E3"),  // Sky Blue
        Color(hex: "D63031"),  // Crimson
        Color(hex: "FDCB6E"),  // Gold
        Color(hex: "55EFC4"),  // Aqua
        
        Color(hex: "A55EEA"),  // Orchid
        Color(hex: "F8A5C2"),  // Blush
        Color(hex: "63CDDA"),  // Ocean
        Color(hex: "EA8685"),  // Salmon
        Color(hex: "78E08F"),  // Jade
        Color(hex: "F19066"),  // Peach
        Color(hex: "546DE5"),  // Royal Blue
        Color(hex: "E15F41"),  // Brick
        Color(hex: "C44569"),  // Berry
        Color(hex: "574B90"),  // Eggplant
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
    
    private var titles: [String] = []
   
    
    @Published var degree = 0.0
    private let animDuration: Double
    private var animation: Animation
    private var pendingRequestWorkItem: DispatchWorkItem?
    private var notificationObserver: NSObjectProtocol?
    
    private var onSpinEnd: ((Int) -> ())?, getWheelItemIndex: (() -> (Int))?
    
    init(
        animDuration: Double, animation: Animation,
        onSpinEnd: ((Int) -> ())?, getWheelItemIndex: (() -> (Int))?,
       
    ) {
       
        self.animDuration = animDuration
        self.animation = animation
        self.onSpinEnd = onSpinEnd
        self.getWheelItemIndex = getWheelItemIndex
      
    }
    
    func setupNotificationObserver() {
        print("🔔 Setting up notification observer for SpinWheel")
        notificationObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("SpinWheel"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            print("📬 Received SpinWheel notification!")
            self?.spinWheel()
        }
    }
    func updateTitles(_ newTitles: [String]) {
           print("📝 Updating titles in ViewModel: \(newTitles)")
           self.titles = newTitles
       }
    
    func removeNotificationObserver() {
        if let observer = notificationObserver {
            NotificationCenter.default.removeObserver(observer)
            notificationObserver = nil
        }
    }

    private func getWheelStopDegree() -> Double {
//        var index = -1
//        if let method = getWheelItemIndex { index = method() }
//        if index < 0 || index >= titles.count { index = Int.random(in: 0..<titles.count) }
//        index = titles.count - index - 1
//        
//        let itemRange = 360 / titles.count
//        let indexDegree = itemRange * index
//        let freeRange = Int.random(in: 0...itemRange)
//        let freeSpins = (2...20).map({ return $0 * 360 }).randomElement()!
//        let finalDegree = freeSpins + indexDegree + freeRange
//        return Double(finalDegree)
        guard titles.count > 0 else {
                print("⚠️ Spin aborted: No titles")
                return 0
            }

            let safeItemRange = max(1, 360 / titles.count)

            var index = -1
            if let method = getWheelItemIndex {
                index = method()
            }

//            if index < 0 || index >= titles.count {
//                index = Int.random(in: 0..<titles.count)
//            }

        guard index >= 0 && index < titles.count else {
            print("❌ Invalid target index")
            return 0
        }
        
            index = titles.count - index - 1

            let indexDegree = safeItemRange * index
            let freeRange = Int.random(in: 0..<safeItemRange)
            let freeSpins = Int.random(in: 2...6) * 360

            return Double(freeSpins + indexDegree + freeRange)
    }
    
//    func spinWheel() {
//        withAnimation(animation) {
//            self.degree = Double(360 * Int(self.degree / 360)) + getWheelStopDegree()
//        }
//        
//        // Cancel the currently pending item
//        pendingRequestWorkItem?.cancel()
//        
//        // Wrap our request in a work item
//        let requestWorkItem = DispatchWorkItem { [weak self] in
//            if let count = self?.titles.count,
//               let distance = self?.degree.truncatingRemainder(dividingBy: 360) {
//                let pointer = floor(distance/(360/Double(count)))
//                if let onSpinEnd = self?.onSpinEnd {
//                    onSpinEnd(count - Int(pointer) - 1)
//                }
//            }
//        }
//        
//        // Save the new work item and execute it after duration
//        pendingRequestWorkItem = requestWorkItem
//        DispatchQueue.main.asyncAfter(deadline: .now() + animDuration + 1, execute: requestWorkItem)
//    }
    func spinWheel(onCompleted: (() -> Void)? = nil) {
        print("🎰 spinWheel() called in FortuneWheelViewModel")
        print("   Titles count:", titles.count)

        // 🚫 HARD STOP CONDITIONS
        guard !titles.isEmpty else {
            print("❌ Spin blocked: titles empty")
            onCompleted?()   // ✅ safely complete
            return
        }

        guard let index = getWheelItemIndex?(),
              index >= 0,
              index < titles.count else {
            print("❌ Spin blocked: invalid winner index")
            onCompleted?()   // ✅ safely complete
            return
        }

        let stopDegree = getWheelStopDegree()

        withAnimation(animation) {
            degree = Double(360 * Int(degree / 360)) + stopDegree
        }

        pendingRequestWorkItem?.cancel()

        let requestWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }

            let count = self.titles.count
            let distance = self.degree.truncatingRemainder(dividingBy: 360)
            let pointer = floor(distance / (360 / Double(count)))
            let finalIndex = count - Int(pointer) - 1

            guard finalIndex >= 0 && finalIndex < count else {
                print("❌ Final index invalid:", finalIndex)
                onCompleted?()
                return
            }

            print("🎯 Wheel stopped at index:", finalIndex)
            self.onSpinEnd?(finalIndex)

            onCompleted?()   // ✅ COMPLETE HERE
        }

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
                    
                    Text(labels[index])
                        .foregroundColor(Color.white)
                        .fontWeight(.bold)
                        .font(.custom(poppinsRegular, size: calculateFontSize(for: geo.size, labelCount: labels.count, text: labels[index])))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.center)
                        .frame(width: calculateLabelWidth(for: geo.size))
                        .offset(viewOffset(for: index, in: geo.size))
                        .zIndex(1)
                    
                    
                }
            }
        }
        .background(Color.clear)
    }
    private func calculateFontSize(for size: CGSize, labelCount: Int, text: String) -> CGFloat {
        let wheelSize = min(size.width, size.height)
        let baseSize: CGFloat
        
        // Adjust base size according to number of items
        switch labelCount {
        case 1...3:
            baseSize = wheelSize * 0.08  // Larger font for few items
        case 4...6:
            baseSize = wheelSize * 0.06  // Medium font
        case 7...10:
            baseSize = wheelSize * 0.05  // Smaller font
        default:
            baseSize = wheelSize * 0.04  // Very small for many items
        }
        
        // Further adjust based on text length
        let textLength = CGFloat(text.count)
        if textLength > 15 {
            return baseSize * 0.7
        } else if textLength > 10 {
            return baseSize * 0.85
        }
        
        return baseSize
    }
    
    // Calculate available width for label based on wheel segment
    private func calculateLabelWidth(for size: CGSize) -> CGFloat {
        let wheelSize = min(size.width, size.height)
        let radius = wheelSize / 3
        
        // Width is proportional to the radius and number of segments
        let segmentAngle = 2 * .pi / Double(labels.count)
        let availableWidth = radius * CGFloat(sin(segmentAngle / 2)) * 1.5
        
        return max(availableWidth, 40) // Minimum width of 40
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
        let wheelRadius = min(size.width, size.height) / 2
        let textRadius = wheelRadius * 0.65 // Position text at 65% of wheel radius
        
        let dataRatio = (2 * data[..<index].reduce(0, +) + data[index]) / (2 * data.reduce(0, +))
        let angle = CGFloat(sliceOffset + 2 * .pi * dataRatio)
        
        return CGSize(width: textRadius * cos(angle), height: textRadius * sin(angle))
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
