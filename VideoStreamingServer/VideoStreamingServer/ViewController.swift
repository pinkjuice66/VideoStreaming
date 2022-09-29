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
    
    let layer = AVSampleBufferDisplayLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layer.frame = view.frame
        view.layer.addSublayer(layer)
        
        do {
            try videoServer.start(on: 12005)
            videoServer.setSampleBufferCallback { [layer] sample in
                layer.enqueue(sample)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

