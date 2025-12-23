//
//  LivePollViewerView.swift
//  BidCast
//
//  Created by JamTech on 20/11/25.
//

import SwiftUI
import Combine

// Viewer view:
struct LivePollViewerView: View {
    @State var poll: PollModel
    var onVote: ((_ poll: PollModel) -> Void)? // emit socket
    var onRequestRefresh: (() -> Void)? // optional: ask server for updated stats

    // local viewer state
    @State private var selectedOption: String? = nil
    @State private var hasVoted: Bool = false
    @State private var isSubmitting: Bool = false

    // timer
    @State private var remainingSeconds: Int
    private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // animation namespace (optional)
    @Namespace private var ns

    init(poll: PollModel,
         onVote: ((_ poll: PollModel) -> Void)? = nil,
         onRequestRefresh: (() -> Void)? = nil)
    {
        _poll = State(initialValue: poll)
        _remainingSeconds = State(initialValue: timerStringToSeconds(poll.remainingTime) ?? 0)
        self.onVote = onVote
        self.onRequestRefresh = onRequestRefresh
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {

                header
                    .padding(.horizontal)

                questionCard
                    .padding(.horizontal)

                timerAndVotes
                    .padding(.horizontal)

                Text("Options")
                    .font(.custom(poppinsSemiBold, size: 16))
                    .padding(.horizontal)

                VStack(spacing: 12) {
                    ForEach(poll.options.indices, id: \.self) { index in
                        let option = poll.options[index]

                        if !hasVoted && poll.isActive {
                            ViewerOptionSelectableRow(
                                optionText: option.text,
                                isSelected: selectedOption == option.text,
                                onTap: {
                                    vote(
                                        optionText: option.text,
                                        optionIndex: index
                                    )
                                }
                            )
                            .padding(.horizontal)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        } else {
                            ViewerOptionStatsRow(
                                option: option,
                                percentage: option.percentage,
                                isSelected: selectedOption == option.text,
                                animateToPercentage: option.percentage
                            )
                            .padding(.horizontal)
                            .animation(.easeInOut(duration: 0.45), value: option.percentage)
                        }
                    }                }
                .padding(.top, 6)

                // If user hasn't voted but poll inactive, show disabled state
                if !poll.isActive && !hasVoted {
                    Text("Poll has ended")
                        .font(.custom(poppinsRegular, size: 13))
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                }

                Spacer(minLength: 12)
            }
            .padding(.bottom, 18)
        }
        .onReceive(timer) { _ in
            guard poll.isActive else { return }
            if remainingSeconds > 0 {
                remainingSeconds -= 1
                poll.remainingTime = timeString(from: remainingSeconds)
            } else {
                poll.isActive = false
                // optionally request server for final stats:
                onRequestRefresh?()
            }
        }
        .onAppear {
            remainingSeconds = timerStringToSeconds(poll.remainingTime)
        }
    }

    // MARK: UI parts

    private var header: some View {
        HStack {
            Text("Live Poll")
                .font(.custom(poppinsBold, size: 22))
            Spacer()
            // you can add an info or close button here if needed
        }
        .padding(.top, 8)
    }

    private var questionCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Question")
                .font(.custom(poppinsSemiBold, size: 14))
                .foregroundColor(.blue)
            Text(poll.question)
                .font(.custom(poppinsRegular, size: 15))
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color.defaultTheme.opacity(0.10))
        .cornerRadius(14)
    }

    private var timerAndVotes: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "timer")
                    .foregroundColor(.red)
                    .padding(6)
                    .background(Color.red.opacity(0.12))
                    .cornerRadius(10)
                Text(timeString(from: remainingSeconds))
                    .font(.custom(poppinsMedium, size: 14))
                    .foregroundColor(.red)
            }

            Spacer()

            HStack(spacing: 8) {
                Image(systemName: "list.bullet")
                    .foregroundColor(.blue)
                    .padding(6)
                    .background(Color.defaultTheme.opacity(0.12))
                    .cornerRadius(10)
                Text("\(poll.totalVotes) total votes")
                    .font(.custom(poppinsMedium, size: 14))
                    .foregroundColor(.blue)
            }
        }
    }

    // MARK: Actions

    private func vote(optionText: String, optionIndex: Int) {
        guard poll.isActive else { return }
        guard !hasVoted else { return }
        // set local state
        selectedOption = optionText
        hasVoted = true
        isSubmitting = true

        // optimistic update (nice UX) — update local counts & percentages immediately
        var updated = poll
        updated.totalVotes += 1
        updated.options[optionIndex].voteCount += 1

        // recompute percentages safely
        updated.options = updated.options.map { opt in
            var m = opt
            let tv = max(1, updated.totalVotes)
            m.percentage = Double(m.voteCount) / Double(tv) * 100.0
            return m
        }

        // animate assignment to poll (triggers progress anim)
        withAnimation(.easeInOut(duration: 0.3)) {
            poll = updated
        }

        // call socket emitter / API callback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            onVote?(updated)
            isSubmitting = false
        }
    }

    // When server sends updated poll (call this externally)
    func applyServerUpdate(_ updatedPoll: PollModel) {
        // ensure state persistence — preserve viewer's selected option / hasVoted
        // server is authoritative for counts & percentages
        withAnimation(.easeInOut(duration: 0.35)) {
            self.poll = updatedPoll
            // if server shows viewer has voted, optionally set hasVoted true
            if let sel = selectedOption, updatedPoll.options.contains(where: { $0.text == sel && $0.voteCount > 0 }) {
                hasVoted = true
            }
        }
    }

    private func timeString(from seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}

// MARK: - Selectable option row (before vote)
// radio button + tappable card with overlay border when pressed/selected
struct ViewerOptionSelectableRow: View {
    var optionText: String
    var isSelected: Bool
    var onTap: () -> Void

    @State private var isPressed: Bool = false

    var body: some View {
        Button(action: {
            Haptics.selection()
            onTap()
        }) {
            HStack(spacing: 14) {

                // MARK: - Custom Radio Button
                ZStack {
                    Circle()
                        .stroke(
                            isSelected ? Color.defaultTheme : Color.gray.opacity(0.4),
                            lineWidth: isSelected ? 3 : 1.5
                        )
                        .frame(width: 22, height: 22)

                    if isSelected {
                        Circle()
                            .fill(Color.defaultTheme)
                            .frame(width: 12, height: 12)
                    }
                }

                // MARK: - Option Text
                Text(optionText)
                    .font(.custom(poppinsMedium, size: 15))
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, alignment: .leading)

            // MARK: - Card Background
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.defaultTheme.opacity(0.08) : Color(UIColor.secondarySystemBackground))
            )

            // MARK: - Border Highlight
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.defaultTheme : Color.clear, lineWidth: 1.8)
            )

            // MARK: - Press Animation
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.30, dampingFraction: 0.70), value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation { isPressed = true }
                }
                .onEnded { _ in
                    withAnimation { isPressed = false }
                }
        )
    }
}


// MARK: - Stats row (after vote) with animated bar and highlight for chosen option

struct ViewerOptionStatsRow: View {
    var option: PollOption
    var percentage: Double
    var isSelected: Bool
    var animateToPercentage: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(option.text.capitalized)
                    .font(.custom(poppinsRegular, size: 15))
                    .foregroundColor(.primary)
                Spacer()
                Text("\(option.voteCount) vote" + (option.voteCount == 1 ? "" : "s"))
                    .font(.custom(poppinsRegular, size: 12))
                    .foregroundColor(.gray)
            }

            GeometryReader { g in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(white: 0.95))
                        .frame(height: 10)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(LinearGradient(gradient: Gradient(colors: [Color.defaultTheme, Color.defaultTheme.opacity(0.8)]),
                                             startPoint: .leading, endPoint: .trailing))
                        .frame(width: barWidth(total: g.size.width, pct: animateToPercentage), height: 10)
                        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: animateToPercentage)

                    // percentage text inside right side
                    HStack {
                        Spacer()
                        Text(String(format: "%.0f%%", percentage))
                            .font(.custom(poppinsSemiBold, size: 12))
                            .foregroundColor(.blue)
                            .padding(.trailing, 6)
                    }
                }
            }
            .frame(height: 18)
        }
        .padding()
        .background(isSelected ? Color.defaultTheme.opacity(0.08) : Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.defaultTheme : Color.clear, lineWidth: isSelected ? 1.6 : 0)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 4)
    }

    private func barWidth(total: CGFloat, pct: Double) -> CGFloat {
        let safe = max(0, total - 8)
        return safe * CGFloat(min(max(pct, 0), 100) / 100)
    }
}

// MARK: - small haptics helper
struct Haptics {
    static func selection() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }
}

// MARK: - Preview
//
//struct LivePollViewerView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            DemoContainerView()
//                .preferredColorScheme(.light)
//        }
//    }
//
//    struct DemoContainerView: View {
//        @State var poll = PollModel(
//            pollId: "123",
//            roomId: "room_01",
//            question: "Which color do you prefer?",
//            options: [
//                PollOption(text: "Red", voteCount: 10, percentage: 40),
//                PollOption(text: "Blue", voteCount: 15, percentage: 60),
//                PollOption(text: "Green", voteCount: 0, percentage: 0)
//            ],
//            totalVotes: 25,
//            remainingTime: 120,
//            isActive: true
//        )
//
//        var body: some View {
//            VStack {
//                LivePollViewerView(poll: poll, onVote: { pollId, roomId, opt in
//                    print("Vote emitted:", opt)
//                }, onRequestRefresh: {
//                    print("request refresh")
//                })
//                .padding(.top, 20)
//            }
//            .onAppear {
//                // simulate server update after 5 seconds
//                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//                    poll.options[2].voteCount = 2
//                    poll.totalVotes = 27
//                    poll.options = poll.options.map { opt in
//                        var m = opt
//                        m.percentage = Double(m.voteCount) / Double(poll.totalVotes) * 100
//                        return m
//                    }
//                }
//            }
//        }
//    }
//}
