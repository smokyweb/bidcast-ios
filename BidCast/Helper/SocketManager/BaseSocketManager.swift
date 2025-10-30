//
//  BaseSocketManager.swift
//  BidCast
//
//  Created by JamTech on 29/10/25.
//
import Foundation
import SocketIO
import os.log

@MainActor
final class BaseSocketManager: ObservableObject {
    static let shared = BaseSocketManager()

    @Published private(set) var isConnected = false
    let logger = Logger(subsystem: "io.bidcast", category: "Socket")

    private var socketManager: SocketManager!
    private(set) var socket: SocketIOClient!

    private init() {
        setupSocket()
    }

    func setupSocket() {
        socketManager = SocketManager(
            socketURL: URL(string: "https://node.bidcast.betaplanets.com")!,
            config: [.compress, .reconnects(true), .path("/socket.io"), .log(false)]
        )
        socket = socketManager.defaultSocket
        setupDefaultListeners()
        socket.connect()
    }

    func disconnect() {
        socket.disconnect()
        socket.removeAllHandlers()
        isConnected = false
        logger.info("🔌 Socket manually disconnected")
    }

    func performIfConnected(_ action: () -> Void) {
        guard socket.status == .connected else {
            if socket.status == .notConnected {
                logger.warning("⚠️ Reconnecting socket...")
                setupSocket()
            }
            return
        }
        action()
    }

    private func setupDefaultListeners() {
        socket.on(clientEvent: .connect) { [weak self] _, _ in
            self?.isConnected = true
            self?.logger.info("✅ Socket connected")
        }

        socket.on(clientEvent: .disconnect) { [weak self] data, _ in
            self?.isConnected = false
            self?.logger.warning("❌ Socket disconnected: \(String(describing: data))")
        }

        socket.on(clientEvent: .error) { [weak self] data, _ in
            self?.logger.error("⚠️ Socket error: \(String(describing: data))")
        }
    }
}
