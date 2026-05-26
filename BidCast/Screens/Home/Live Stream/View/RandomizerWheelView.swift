// RandomizerWheelView.swift
// BidCast — Buyer-side spinning wheel that handles all 4 randomizer types
// Build 313 / 2026-05-26
//
// Usage: replaces the VerticalShuffleView in Randomizer.swift for template-based shows.
// Listens for freebie-spinning, get-freebie (with template slots), get-freebie-winner.

import SwiftUI

// MARK: - Main Buyer Wheel View
struct RandomizerWheelView: View {

    @Binding var roomId: String
    @StateObject private var vm = RandomizerWheelViewModel()

    var body: some View {
        ZStack {
            Color.black.opacity(0.01).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: 0) {
                    // Type badge
                    if let type = vm.templateType {
                        Text(type.displayName)
                            .font(.custom(poppinsBold, size: 13))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 5)
                            .background(Color.defaultTheme)
                            .cornerRadius(12)
                            .padding(.top, 16)
                    }

                    // Wheel
                    if !vm.slots.isEmpty {
                        templateWheel
                    } else {
                        legacyWheel
                    }

                    // Winner banner
                    if let winner = vm.winnerName {
                        winnerBanner(name: winner)
                    }

                    // Entry cost info
                    if let cost = vm.entryCost, cost > 0 {
                        Text(String(format: "Entry: $%.2f", cost))
                            .font(.custom(poppinsBold, size: 14))
                            .foregroundColor(.defaultTheme)
                            .padding(.top, 8)
                    }

                    Spacer().frame(height: 24)
                }
                .background(Color.backGround)
                .cornerRadius(24, corners: [.topLeft, .topRight])
            }
        }
        .onAppear { vm.subscribe(roomId: roomId) }
        .onDisappear { vm.unsubscribe() }
    }

    // MARK: - Template-based wheel (colored segments with icons)
    @ViewBuilder
    private var templateWheel: some View {
        let size = UIScreen.main.bounds.width / 1.3

        ZStack(alignment: .top) {
            ZStack(alignment: .center) {
                // Wheel body
                TemplateWheelCanvas(slots: vm.slots, size: size, rotationDegrees: vm.rotationDegrees)
                    .frame(width: size, height: size)
                    .overlay(
                        RoundedRectangle(cornerRadius: size / 2)
                            .stroke(Color.white, lineWidth: 6)
                    )
                    .shadow(radius: 8)

                // Center bolt
                SpinWheelBolt()
            }

            // Pointer
            SpinWheelPointer(pointerColor: Color(hex: "DA4533"))
        }
        .padding(20)
        .animation(.timingCurve(0.51, 0.97, 0.56, 0.99, duration: vm.animDuration), value: vm.rotationDegrees)
    }

    // MARK: - Legacy text-based wheel (when no template data)
    @ViewBuilder
    private var legacyWheel: some View {
        if !vm.participantNames.isEmpty {
            FortuneWheel(
                titles: $vm.participantNames,
                spinTrigger: $vm.spinTrigger,
                size: UIScreen.main.bounds.width / 1.5,
                onSpinEnd: vm.handleSpinEnd
            )
            .padding()
        } else {
            VStack(spacing: 12) {
                ProgressView()
                Text("Waiting for participants…")
                    .font(.custom(poppinsRegular, size: 14))
                    .foregroundColor(.gray)
            }
            .frame(height: 200)
        }
    }

    // MARK: - Winner banner
    func winnerBanner(name: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "trophy.fill")
                .foregroundColor(.yellow)
            Text("\(name) wins!")
                .font(.custom(poppinsBold, size: 16))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.green)
        .cornerRadius(20)
        .padding(.top, 12)
        .transition(.scale.combined(with: .opacity))
    }
}

// MARK: - Template Wheel Canvas
/// Draws colored pie segments with icon/label text for each slot
struct TemplateWheelCanvas: View {
    let slots: [TemplateWheelSlot]
    let size: CGFloat
    let rotationDegrees: Double

    var body: some View {
        Canvas { context, csize in
            let center = CGPoint(x: csize.width / 2, y: csize.height / 2)
            let radius = min(csize.width, csize.height) / 2
            let slotAngle = 360.0 / Double(slots.count)

            for (idx, slot) in slots.enumerated() {
                let startAngle = Angle(degrees: Double(idx) * slotAngle - 90)
                let endAngle   = Angle(degrees: Double(idx + 1) * slotAngle - 90)

                // Fill segment
                var path = Path()
                path.move(to: center)
                path.addArc(center: center, radius: radius,
                            startAngle: startAngle, endAngle: endAngle,
                            clockwise: false)
                path.closeSubpath()
                context.fill(path, with: .color(slot.displayColor))

                // Stroke segment border
                context.stroke(path, with: .color(.white.opacity(0.3)), lineWidth: 1.5)

                // Icon / label text
                let midAngle = Double(idx) * slotAngle + slotAngle / 2 - 90
                let textRadius = radius * 0.62
                let textX = center.x + textRadius * CGFloat(cos(midAngle * .pi / 180))
                let textY = center.y + textRadius * CGFloat(sin(midAngle * .pi / 180))

                let label = slot.icon ?? slot.displayLabel
                context.draw(
                    Text(label)
                        .font(.system(size: max(10, 28 / Double(slots.count) * 2.0)))
                        .foregroundColor(.white),
                    at: CGPoint(x: textX, y: textY)
                )
            }
        }
        .rotationEffect(.degrees(rotationDegrees))
    }
}

// MARK: - ViewModel
@MainActor
final class RandomizerWheelViewModel: ObservableObject {

    @Published var slots: [TemplateWheelSlot] = []
    @Published var participantNames: [String] = []
    @Published var spinTrigger = false
    @Published var rotationDegrees: Double = 0
    @Published var templateType: RandomizerType? = nil
    @Published var entryCost: Double? = nil
    @Published var winnerName: String? = nil
    @Published var isSpinning = false

    let animDuration: Double = 4.0
    private var roomId = ""
    private var targetSlotIndex: Int? = nil
    private var baseRotation: Double = 0

    @Published var socketManager = SocketManagerService.shared

    // MARK: - Subscribe
    func subscribe(roomId: String) {
        self.roomId = roomId

        // freebie-spinning → pre-spin anticipation
        socketManager.listenForFreebieSpinning { [weak self] rid in
            guard let self, rid == self.roomId else { return }
            Task { @MainActor in
                self.startSpinAnimation(targetIndex: nil)
            }
        }

        // get-freebie → populate wheel with template slots
        socketManager.listenForTemplateFreebieData { [weak self] payload in
            guard let self, payload.freebie?.room_id == self.roomId else { return }
            Task { @MainActor in
                self.populateFromTemplatePayload(payload)
            }
        }

        // get-freebie (legacy) → populate participant names
        socketManager.listenForFreebie { [weak self] freebie, users in
            guard let self, freebie.room_id == self.roomId else { return }
            Task { @MainActor in
                if self.slots.isEmpty {
                    self.participantNames = users.map { $0.name ?? "" }
                }
            }
        }

        // get-freebie-winner → stop on winning slot
        socketManager.listenForFreebieWinner { [weak self] winner in
            Task { @MainActor in
                guard let self else { return }
                self.handleWinner(winner)
            }
        }
    }

    func unsubscribe() {
        // Socket events auto-clear when view disappears;
        // SocketManagerService handles deregistration on reconnect
    }

    // MARK: - Populate from template payload
    private func populateFromTemplatePayload(_ payload: RandomizerFreebiePayload) {
        if let typeStr = payload.template_type, let type = RandomizerType(rawValue: typeStr) {
            templateType = type
        }
        entryCost = payload.entry_cost
        if let rawSlots = payload.slots {
            slots = rawSlots.map { s in
                TemplateWheelSlot(
                    id: s.id,
                    position: s.position,
                    color: s.color,
                    icon: s.icon,
                    product_id: s.product_id,
                    product: s.product
                )
            }
        }
    }

    // MARK: - Spin animation
    func startSpinAnimation(targetIndex: Int?) {
        guard !isSpinning else { return }
        isSpinning = true
        winnerName = nil

        let slotCount = max(1, slots.isEmpty ? max(1, participantNames.count) : slots.count)
        let fullRotations = 5 * 360.0
        let slotAngle = 360.0 / Double(slotCount)

        if let idx = targetIndex {
            // Land precisely on winning slot
            let targetOffset = Double(idx) * slotAngle + slotAngle / 2
            rotationDegrees = baseRotation + fullRotations + (360.0 - targetOffset)
        } else {
            // Spin freely (winner not yet known)
            rotationDegrees = baseRotation + fullRotations + Double.random(in: 0..<360)
        }
        baseRotation = rotationDegrees

        // Also trigger the FortuneWheel for legacy mode
        spinTrigger.toggle()

        DispatchQueue.main.asyncAfter(deadline: .now() + animDuration + 0.5) { [weak self] in
            self?.isSpinning = false
        }
    }

    func handleSpinEnd(_ index: Int) {
        isSpinning = false
    }

    // MARK: - Handle winner
    private func handleWinner(_ user: FreebieUser) {
        winnerName = user.name

        // Find winner slot for template wheel
        if !slots.isEmpty, let idx = participantNames.firstIndex(of: user.name ?? "") {
            startSpinAnimation(targetIndex: idx % slots.count)
        } else if !isSpinning {
            // Just announce
            withAnimation { winnerName = user.name }
        }
    }
}
