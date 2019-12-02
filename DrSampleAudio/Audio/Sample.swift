//
//  Sample.swift
//  DrSampleAudio
//
//  Created by Adam Bellard on 11/1/19.
//  Copyright © 2019 Adam Bellard. All rights reserved.
//

import UIKit
import AVFoundation

enum PlaybackStyle {
    case loop
    case oneShot
    case reverse
    case trigger
}

class Sample {
    var style: PlaybackStyle = .loop
    
    var playBuffer: AVAudioPCMBuffer? {
        return style == .reverse ? reverseBuffer : buffer
    }
    
    var reverseBuffer: AVAudioPCMBuffer?
    var buffer: AVAudioPCMBuffer?
    var file: AVAudioFile?
    
    var isPlaying: Bool = false
    
    var node: AVAudioPlayerNode?
    
    init(url: URL) {
        try? file = AVAudioFile(forReading: url)
        
        if let format = file?.processingFormat, let length = file?.length {
            guard let audioBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(length)) else { return }

            try? file?.read(into: audioBuffer)
            buffer = audioBuffer
            
            if let buff = buffer {
                reverseBuffer = Sample.reverseBuffer(buff)
            }
        }
    }
    
    static func reverseBuffer(_ buffer: AVAudioPCMBuffer) -> AVAudioPCMBuffer? {
        
        guard let newBuffer = AVAudioPCMBuffer(pcmFormat: buffer.format, frameCapacity: buffer.frameCapacity) else { return nil }
        
        let audioBufferList = UnsafeMutableAudioBufferListPointer(newBuffer.mutableAudioBufferList)
        
        if let samples = buffer.floatChannelData {
            for channel in 0 ..< Int(buffer.format.channelCount) {
                
                let readBuffer = samples[channel]
                let writeBuffer = audioBufferList[channel]
                guard let writeData = writeBuffer.mData else { continue }
                let writeSamples = UnsafeMutablePointer<Float>(OpaquePointer(writeData))
                
                var writeIndex = 0
                for index in (0 ..< Int(buffer.frameLength)).reversed() {
                    writeSamples[writeIndex] = readBuffer[index]
                    
                    if buffer.format.isInterleaved {
                        writeSamples[writeIndex + 1] = readBuffer[index + 1]
                    }
                    
                    writeIndex += buffer.stride
                }
            }
        } else if let samples = buffer.int16ChannelData {
            for channel in 0 ..< Int(buffer.format.channelCount) {
                
                let readBuffer = samples[channel]
                let writeBuffer = audioBufferList[channel]
                guard let writeData = writeBuffer.mData else { continue }
                let writeSamples = UnsafeMutablePointer<Int16>(OpaquePointer(writeData))
                
                var writeIndex = 0
                for index in (0 ..< Int(buffer.frameLength)).reversed() {
                    writeSamples[writeIndex] = readBuffer[index]
                    
                    if buffer.format.isInterleaved {
                        writeSamples[writeIndex + 1] = readBuffer[index + 1]
                    }
                    
                    writeIndex += buffer.stride
                }
            }
        } else if let samples = buffer.int32ChannelData {
            for channel in 0 ..< Int(buffer.format.channelCount) {
                
                let readBuffer = samples[channel]
                let writeBuffer = audioBufferList[channel]
                guard let writeData = writeBuffer.mData else { continue }
                let writeSamples = UnsafeMutablePointer<Int32>(OpaquePointer(writeData))
                
                var writeIndex = 0
                for index in (0 ..< Int(buffer.frameLength)).reversed() {
                    writeSamples[writeIndex] = readBuffer[index]
                    
                    if buffer.format.isInterleaved {
                        writeSamples[writeIndex + 1] = readBuffer[index + 1]
                    }
                    
                    writeIndex += buffer.stride
                }
            }
        }
        
        return newBuffer
    }
}
