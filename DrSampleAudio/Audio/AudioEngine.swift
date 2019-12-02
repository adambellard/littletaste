//
//  AudioEngine.swift
//  DrSampleAudio
//
//  Created by Adam Bellard on 11/1/19.
//  Copyright © 2019 Adam Bellard. All rights reserved.
//

import UIKit
import AVFoundation

class AudioEngine {
    static let sharedInstance = AudioEngine()

    let engine = AVAudioEngine()
    
    init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true, options: [])
        
        engine.connect(engine.mainMixerNode, to: engine.outputNode, format: engine.mainMixerNode.outputFormat(forBus: 0))
        try? engine.start()
    }
    
    func add(_ sample: Sample) {
        let node = AVAudioPlayerNode()
        engine.attach(node)
        if let format = sample.buffer?.format {
            engine.connect(node, to: engine.mainMixerNode, format: format)
        }
        sample.node = node
    }
    
    func togglePlayback(sample: Sample) {
        sample.isPlaying = !sample.isPlaying
        
        if sample.isPlaying {
            if let buffer = sample.playBuffer, let node = sample.node {
                var options = AVAudioPlayerNodeBufferOptions()
                
                if sample.style == .loop {
                    options.insert(.loops)
                }
                
                node.scheduleBuffer(buffer, at: nil, options: options, completionHandler: nil)
                node.play()
            }
        } else {
            if let node = sample.node {
                node.stop()
            }
        }
    }
}
