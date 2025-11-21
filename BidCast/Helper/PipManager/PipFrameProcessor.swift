//
//  PipFrameProcessor.swift
//  BidCast
//
//  Created by JamTech on 21/11/25.
//

import Foundation
import AgoraRtcKit
import AVFoundation

class AgoraFrameProcessor: NSObject {
    private weak var sampleBufferDisplayLayer: AVSampleBufferDisplayLayer?
    private var pixelBufferPool: CVPixelBufferPool?
    private var currentSize: CGSize = .zero
    private let maxFrameRate: Int32 = 30
    
    private let frameQueue = DispatchQueue(label: "com.agora.pip.frame", qos: .userInteractive)
    private let processingQueue = DispatchQueue(label: "com.agora.pip.processing", qos: .userInteractive)
    private var latestVideoFrame: AgoraOutputVideoFrame?
    private var isProcessing = false
    
    init(displayLayer: AVSampleBufferDisplayLayer) {
        super.init()
        self.sampleBufferDisplayLayer = displayLayer
        displayLayer.videoGravity = .resizeAspectFill
    }
    
    func processVideoFrame(_ videoFrame: AgoraOutputVideoFrame) {
        frameQueue.async { [weak self] in
            self?.handleNewFrame(videoFrame)
        }
    }
    
    private func handleNewFrame(_ frame: AgoraOutputVideoFrame) {
        latestVideoFrame = frame
        
        if !isProcessing {
            processNextFrame()
        }
    }
    
    private func processNextFrame() {
        guard !isProcessing,
              let frame = latestVideoFrame,
              let displayLayer = sampleBufferDisplayLayer else { return }
        
        isProcessing = true
        
        processingQueue.async { [weak self] in
            guard let self = self else { return }
            
            autoreleasepool {
                if let pixelBuffer = self.createPixelBuffer(from: frame),
                   let sampleBuffer = self.createSampleBuffer(from: pixelBuffer) {
                    DispatchQueue.main.async {
                        displayLayer.enqueue(sampleBuffer)
                        self.isProcessing = false
                        
                        // Process next frame if available
                        if self.latestVideoFrame !== frame {
                            self.processNextFrame()
                        }
                    }
                } else {
                    self.isProcessing = false
                }
            }
        }
    }
    
    private func createPixelBuffer(from frame: AgoraOutputVideoFrame) -> CVPixelBuffer? {
        let width = Int(frame.width)
        let height = Int(frame.height)
        
        var pixelBuffer: CVPixelBuffer?
        let attrs = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferMetalCompatibilityKey as String: true,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:]
        ] as [String: Any]
        
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            attrs as CFDictionary,
            &pixelBuffer
        )
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
        
        guard let baseAddress = CVPixelBufferGetBaseAddress(buffer) else {
            return nil
        }
        
        let bytesPerRow = CVPixelBufferGetBytesPerRow(buffer)
        let bgraBuffer = baseAddress.assumingMemoryBound(to: UInt8.self)
        
        // Convert YUV to BGRA
        convertYUVtoBGRA(
            frame: frame,
            bgraBuffer: bgraBuffer,
            bytesPerRow: bytesPerRow,
            width: width,
            height: height
        )
        
        return buffer
    }
    
    private func convertYUVtoBGRA(
        frame: AgoraOutputVideoFrame,
        bgraBuffer: UnsafeMutablePointer<UInt8>,
        bytesPerRow: Int,
        width: Int,
        height: Int
    ) {
        guard let yBuffer = frame.yBuffer,
              let uBuffer = frame.uBuffer,
              let vBuffer = frame.vBuffer else { return }
        
        let yStride = Int(frame.yStride)
        let uStride = Int(frame.uStride)
        let vStride = Int(frame.vStride)
        
        for row in 0..<height {
            for col in 0..<width {
                let yIndex = row * yStride + col
                let uvIndex = (row / 2) * uStride + (col / 2)
                
                let y = Int(yBuffer[yIndex])
                let u = Int(uBuffer[uvIndex]) - 128
                let v = Int(vBuffer[uvIndex]) - 128
                
                // YUV to RGB conversion
                var r = (y * 298 + v * 409 + 128) >> 8
                var g = (y * 298 - u * 100 - v * 208 + 128) >> 8
                var b = (y * 298 + u * 516 + 128) >> 8
                
                // Clamp values
                r = max(0, min(255, r))
                g = max(0, min(255, g))
                b = max(0, min(255, b))
                
                let pixelOffset = row * bytesPerRow + col * 4
                
                // BGRA format
                bgraBuffer[pixelOffset + 0] = UInt8(b)     // B
                bgraBuffer[pixelOffset + 1] = UInt8(g)     // G
                bgraBuffer[pixelOffset + 2] = UInt8(r)     // R
                bgraBuffer[pixelOffset + 3] = 255          // A
            }
        }
    }
    
    private func createSampleBuffer(from pixelBuffer: CVPixelBuffer) -> CMSampleBuffer? {
        var sampleBuffer: CMSampleBuffer?
        
        var timing = CMSampleTimingInfo()
        timing.presentationTimeStamp = CMTime(seconds: CACurrentMediaTime(), preferredTimescale: 90000)
        timing.duration = CMTime(value: 1, timescale: maxFrameRate)
        timing.decodeTimeStamp = .invalid
        
        var formatDesc: CMFormatDescription?
        CMVideoFormatDescriptionCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: pixelBuffer,
            formatDescriptionOut: &formatDesc
        )
        
        if let formatDesc = formatDesc {
            CMSampleBufferCreateForImageBuffer(
                allocator: kCFAllocatorDefault,
                imageBuffer: pixelBuffer,
                dataReady: true,
                makeDataReadyCallback: nil,
                refcon: nil,
                formatDescription: formatDesc,
                sampleTiming: &timing,
                sampleBufferOut: &sampleBuffer
            )
        }
        
        return sampleBuffer
    }
    
    deinit {
        pixelBufferPool = nil
        sampleBufferDisplayLayer?.flushAndRemoveImage()
    }
}




