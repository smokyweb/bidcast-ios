//
//  LivePollView.swift
//  BidCast
//
//  Created by JamTech on 20/11/25.
//

import SwiftUI
import Combine

// MARK: - Models

struct PollOption: Codable {
    var text: String
    var voteCount: Int
    var percentage: Double   // use 0...100
}
struct TextModel : Codable {
    var text: String
    var vote_count: Int
    var percentage: Double
}

struct PollModel: Codable {
    var pollId: Int
    var roomId: String
    var question: String
    var options: [PollOption]
    var totalVotes: Int
    var remainingTime: String // seconds
    var isActive: Bool
}

// MARK: - Live Poll Host View

struct LivePollHostView: View {
    @State var poll: PollModel
    var onEndPoll: ((String, String) -> Void)?    // (pollId, roomId)
    
    // Timer
    @State private var timerSubscription: Cancellable? = nil
    @State private var remainingSeconds: Int
    @State private var now = Date()
    var onCancel: (() -> Void)?
    // Animation namespace (optional for matched animations)
    @Namespace private var ns
    
    init(poll: PollModel, onEndPoll: ((String, String) -> Void)? = nil,onCancel:(() -> Void)? = nil) {
        _poll = State(initialValue: poll)
        _remainingSeconds = State(initialValue: timerStringToSeconds(poll.remainingTime))
        self.onEndPoll = onEndPoll
        self.onCancel = onCancel
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    Text("Live Poll")
                        .font(.custom(poppinsBold, size: 22.0))
                        .foregroundStyle(.black)
                    Spacer()
                    Button(action: {
                        onCancel?()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.custom(poppinsSemiBold, size: 28.0))
                            .foregroundStyle(.black)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 6)
                
                // Question card
                VStack(alignment: .leading, spacing: 8) {
                    Text("Question")
                        .frame(maxWidth: .infinity)
                        .font(.custom(poppinsSemiBold, size: 14))
                        .foregroundStyle(.black)
                    Text(poll.question)
                        .frame(maxWidth: .infinity)
                        .font(.custom(poppinsRegular, size: 15))
                        .foregroundStyle(.black)
                }
                .padding(.horizontal, 22)
                .padding(.vertical)
                .background(Color.defaultTheme.opacity(0.10))
                .cornerRadius(14)
                //            .padding(.horizontal)
                
                // Timer + total votes
                HStack(spacing: 12) {
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
                    .padding(.vertical, 6)
                    .padding(.horizontal, 6)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Image(systemName: "list.bullet")
                            .foregroundColor(.blue)
                            .padding(6)
                            .background(Color.defaultTheme.opacity(0.12))
                            .cornerRadius(10)
                        Text("\(poll.totalVotes) total votes")
                            .font(.custom(poppinsMedium, size: 14))
                            .foregroundStyle(.black)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 6)
                }
                .padding(.horizontal)
                
                // Options label
                HStack {
                    Text("Options")
                        .font(.custom(poppinsSemiBold, size: 16))
                        .foregroundStyle(.black)
                    Spacer()
                }
                .padding(.horizontal)
                
                // Options list
                VStack(spacing: 12) {
                    ForEach(poll.options, id: \.text) { option in
                        OptionRowView(option: option, percentage: option.percentage)
                            .padding(.horizontal)
                        //                        .overlay(
                        //                            // count label top-right
                        //                            HStack {
                        //                                Spacer()
                        //                                VStack {
                        //                                    Text("\(option.voteCount) vote" + (option.voteCount == 1 ? "" : "s"))
                        //                                        .font(.custom(poppinsRegular, size: 12))
                        //                                        .foregroundColor(.gray)
                        //                                        .padding(.top, 8)
                        //                                        .padding(.trailing, 18)
                        //                                    Spacer()
                        //                                }
                        //                            }
                        //                        )
                            .animation(.easeInOut(duration: 0.5), value: option.percentage)
                    }
                }
                .padding(.top, 4)
                
                Spacer()
                
                // End Poll Button
                Button(action: {
                    // end poll callback
                    poll.isActive = false
                    stopTimer()
                    onEndPoll?("\(poll.pollId)", poll.roomId)
                }) {
                    Text("End Poll")
                        .font(.custom(poppinsSemiBold, size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.defaultTheme)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .disabled(!poll.isActive)
                .opacity(poll.isActive ? 1 : 0.6)
                .padding(.bottom, 30)
            }
            .background(Color(.white))
            .cornerRadius(18)
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .onReceive(timerPublisher) { _ in
            updateCountdown()
        }
    }
    
    // MARK: Timer publisher (fires every second)
    private var timerPublisher: Publishers.Autoconnect<Timer.TimerPublisher> {
        Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    }
    
    private func startTimer() {
        remainingSeconds = timerStringToSeconds(poll.remainingTime)
    }
    
    private func stopTimer() {
        // nothing needed with autoconnect onReceive, but if you use subscription cancel it
    }
    
    private func updateCountdown() {
        guard poll.isActive else { return }
        if remainingSeconds > 0 {
            remainingSeconds -= 1
            // update model's remaining time as well
            poll.remainingTime = timeString(from: remainingSeconds)
        } else {
            poll.isActive = false
            stopTimer()
            // Optionally auto-end poll
            onEndPoll?("\(poll.pollId)", poll.roomId)
        }
    }
    
    private func timeString(from seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
    
   
}

// MARK: - Option row (animated bar)

struct OptionRowView: View {
    var option: PollOption
    var percentage: Double   // 0..100
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(option.text.capitalizingFirstLetter())
                    .font(.custom(poppinsRegular, size: 14))
                    .foregroundStyle(.black)
                Spacer()
                Text("\(option.voteCount) vote" + (option.voteCount == 1 ? "" : "s"))
                    .font(.custom(poppinsRegular, size: 12))
                    .foregroundStyle(.black)
                    .padding(.top, 8)
            }
            .padding(.bottom, 6)
            
            GeometryReader { geo in
                HStack {
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(white: 0.95))
                            .frame(height: 8)
                        
                        // Animated bar
                        RoundedRectangle(cornerRadius: 6)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color.defaultTheme, Color.defaultTheme.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: maxBarWidth(totalWidth: geo.size.width, pct: percentage), height: 8)
                            .animation(.spring(response: 0.45, dampingFraction: 0.8), value: percentage)
                    }
                    Text("\(Int(percentage))%")
                        .font(.custom(poppinsSemiBold, size: 12))
                        .foregroundStyle(.black)
                        .padding(.leading, 8)
                }
            }
            .frame(height: 18)
        }
        .padding()
        .background(.backGround)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
    
    private func maxBarWidth(totalWidth: CGFloat, pct: Double) -> CGFloat {
        // keep a minimum padding so the bar is not full width of card edges
        let safeWidth = max(0, totalWidth - 8)
        return safeWidth * CGFloat(min(max(pct, 0.0), 100.0) / 100)
    }
}

// MARK: - Preview & Demo (simulate updates)

struct LivePollHostView_Previews: PreviewProvider {
    static var previews: some View {
        DemoHostContainer()
            .preferredColorScheme(.light)
    }
    
    struct DemoHostContainer: View {
        @State private var poll = PollModel(
            pollId: 12345,
            roomId: "room_01",
            question: "Do you like the product?",
            options: [
                PollOption(text: "yes",
                           voteCount: 1,
                           percentage: 100),
                PollOption(text: "no",
                           voteCount: 0,
                           percentage: 0),
                PollOption(text: "not very much",
                           voteCount: 0,
                           percentage: 0)
            ],
            totalVotes: 1,
            remainingTime: "02:08",
            isActive: true
        )
        
        var body: some View {
            VStack {
                LivePollHostView(poll: poll) { pollId, roomId in
                    // End poll action -> call socket.emit("end_poll", payload)
                    print("End poll requested for \(pollId) in \(roomId)")
                }
            }
            .onAppear {
                // Simulate updates for preview
                simulateUpdates()
            }
        }
        
        func simulateUpdates() {
            // After 2s, add a vote to second option
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                poll.options[1].voteCount = 1
                poll.totalVotes = 2
                // recalc percentages
                poll.options = poll.options.map { opt in
                    var m = opt
                    m.percentage = Double(m.voteCount) / Double(poll.totalVotes) * 100.0
                    return m
                }
            }
            // After 4s, add another vote to first option
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                poll.options[0].voteCount = 2
                poll.totalVotes = 3
                poll.options = poll.options.map { opt in
                    var m = opt
                    m.percentage = Double(m.voteCount) / Double(poll.totalVotes) * 100.0
                    return m
                }
            }
        }
    }
}

func timerStringToSeconds(_ time: String) -> Int {
    let parts = time.split(separator: ":")
    guard parts.count == 2,
          let minutes = Int(parts[0]),
          let seconds = Int(parts[1]) else {
        return 0
    }
    return (minutes * 60) + seconds
}
