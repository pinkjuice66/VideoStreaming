//
//  ViewController.swift
//  VideoStreamingServer
//
//  Created by Jade on 2022/09/20.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    let videoServer = VideoServer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layer = AVSampleBufferDisplayLayer()
        layer.frame = view.frame
        view.layer.addSublayer(layer)
        
        try? videoServer.start(on: 12005)
        videoServer.setSampleBufferCallback { sample in
            layer.enqueue(sample)
        }
    }
}

