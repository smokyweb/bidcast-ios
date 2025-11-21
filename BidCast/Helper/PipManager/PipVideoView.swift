//
//  PipVideoView.swift
//  BidCast
//
//  Created by JamTech on 21/11/25.
//

import UIKit
import AgoraRtcKit
import AVKit

class AgoraPiPVideoView: UIView {
    private var frameProcessor: AgoraFrameProcessor?
    private var displayLayer: AVSampleBufferDisplayLayer?
    private var isActive = true
    
    override class var layerClass: AnyClass {
        return AVSampleBufferDisplayLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDisplayLayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupDisplayLayer() {
        displayLayer = layer as? AVSampleBufferDisplayLayer
        displayLayer?.videoGravity = .resizeAspectFill
        displayLayer?.backgroundColor = CGColor(gray: 0, alpha: 1)
        
        if let displayLayer = displayLayer {
            displayLayer.flushAndRemoveImage()
            
            if #available(iOS 13.0, *) {
                displayLayer.preventsDisplaySleepDuringVideoPlayback = true
            }
            
            frameProcessor = AgoraFrameProcessor(displayLayer: displayLayer)
        }
        
        backgroundColor = .black
        isOpaque = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        displayLayer?.frame = bounds
    }
    
    func processVideoFrame(_ videoFrame: AgoraOutputVideoFrame) {
        guard isActive else { return }
        frameProcessor?.processVideoFrame(videoFrame)
    }
    
    func cleanup() {
        isActive = false
        displayLayer?.flushAndRemoveImage()
    }
    
    deinit {
        cleanup()
    }
}
