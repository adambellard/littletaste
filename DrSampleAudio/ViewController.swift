//
//  ViewController.swift
//  DrSampleAudio
//
//  Created by Adam Bellard on 11/1/19.
//  Copyright © 2019 Adam Bellard. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let engine = AudioEngine.sharedInstance
    
    var samples: [Sample]?
    var pads = [UIButton]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        samples = ["2", "1", "0", "3"].compactMap { Bundle.main.path(forResource: $0, ofType: "wav") }.compactMap { URL(fileURLWithPath: $0) }.map { Sample(url: $0) }
        
        samples?[0].style = .loop
        samples?[1].style = .oneShot
        samples?[2].style = .reverse
        samples?[3].style = .trigger
        
        for i in 0 ..< (samples?.count ?? 0) {
            if let sample = samples?[i] {
                engine.add(sample)
            }
            
            let pad = UIButton(type: .custom)
            pad.tag = i
            pad.addTarget(self, action: #selector(padDown(_:)), for: .touchDown)
            pad.addTarget(self, action: #selector(padUp(_:)), for: .touchUpInside)
            pad.addTarget(self, action: #selector(padUp(_:)), for: .touchUpOutside)
            pad.backgroundColor = .gray
            pad.layer.borderWidth = 1
            pad.layer.borderColor = UIColor.black.cgColor
            pads.append(pad)
            view.addSubview(pad)
        }
        
        print(samples)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        for i in 0 ..< pads.count {
            let pad = pads[i]
            let x = CGFloat(i % 2) * view.frame.width / 2
            let y = CGFloat(i / 2) * view.frame.height / 2
            pad.frame = CGRect(x: x, y: y, width: view.frame.width, height: view.frame.height)
        }
    }
    
    @objc func padDown(_ sender: UIButton) {
        if sender.tag >= 0 && sender.tag < samples?.count ?? 0, let sample = samples?[sender.tag] {
            engine.togglePlayback(sample: sample)
            let pad = pads[sender.tag]
            pad.backgroundColor = sample.isPlaying ? UIColor.red : UIColor.gray
        }
    }
    
    @objc func padUp(_ sender: UIButton) {
        if sender.tag >= 0 && sender.tag < samples?.count ?? 0, let sample = samples?[sender.tag] {
            if sample.style == .trigger {
                engine.togglePlayback(sample: sample)
                let pad = pads[sender.tag]
                pad.backgroundColor = sample.isPlaying ? UIColor.red : UIColor.gray
            }
        }
    }

}

