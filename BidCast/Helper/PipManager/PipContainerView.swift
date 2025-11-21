//
//  PipContainerView.swift
//  BidCast
//
//  Created by JamTech on 21/11/25.
//



import UIKit
import AgoraRtcKit

class AgoraPiPContainerView: UIView {
    private let remoteVideoView: AgoraPiPVideoView
    
    override init(frame: CGRect) {
        remoteVideoView = AgoraPiPVideoView(frame: .zero)
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(remoteVideoView)
        
        remoteVideoView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            remoteVideoView.leadingAnchor.constraint(equalTo: leadingAnchor),
            remoteVideoView.trailingAnchor.constraint(equalTo: trailingAnchor),
            remoteVideoView.topAnchor.constraint(equalTo: topAnchor),
            remoteVideoView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        backgroundColor = .black
        remoteVideoView.backgroundColor = .black
    }
    
    func processVideoFrame(_ videoFrame: AgoraOutputVideoFrame) {
        remoteVideoView.processVideoFrame(videoFrame)
    }
    
    func cleanup() {
        remoteVideoView.cleanup()
    }
    
    deinit {
        cleanup()
    }
}

