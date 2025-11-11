//  TimerSocketHandler.swift
//  BidCast
//
//  Created by Vivek_JAM_E-328 on 29/10/25.
//

import Foundation

@MainActor
final class TimerSocketHandler: ObservableObject {
    @Published var showTime: String = "00:00:00"
    @Published var bidTime: String = "00:00:00"
    
    private let base = BaseSocketManager.shared
    private var liveSchedulerTimer: Timer?

    func listenForShowTimer(roomId: String) {
        base.socket.on("show_timer_update") { [weak self] data, _ in
            guard let self,
                  let json = data.first as? [String: Any],
                  let id = json["room_id"] as? String,
                  id == roomId,
                  let elapsed = json["elapsed"] as? Int else { return }
            showTime = formatTime(seconds: elapsed)
        }
    }

    func listenForBidTimer(roomId: String) {
        base.socket.on("bid_timer_update") { [weak self] data, _ in
            guard let self,
                  let json = data.first as? [String: Any],
                  let id = json["room_id"] as? String,
                  id == roomId,
                  let remaining = json["remaining"] as? Int else { return }
            bidTime = formatTime(seconds: remaining)
        }
    }

    func startLiveScheduler(roomId: String) {
        stopLiveScheduler()
        sendLiveScheduler(roomId: roomId)
        liveSchedulerTimer = Timer.scheduledTimer(withTimeInterval: 270, repeats: true) { [weak self] _ in
            self?.sendLiveScheduler(roomId: roomId)
        }
    }

    func stopLiveScheduler() {
        liveSchedulerTimer?.invalidate()
        liveSchedulerTimer = nil
    }

    private func sendLiveScheduler(roomId: String) {
        base.performIfConnected {
            base.socket.emit("liveScheduler", ["room_id": roomId])
            base.logger.info("📡 Sent liveScheduler for \(roomId)")
        }
    }

    private func formatTime(seconds: Int) -> String {
        String(format: "%02d:%02d:%02d", seconds / 3600, (seconds % 3600) / 60, seconds % 60)
    }
}
