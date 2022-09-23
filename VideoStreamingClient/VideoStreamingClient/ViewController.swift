//
//  ViewController.swift
//  VideoStreamingClient
//
//  Created by Jade on 2022/09/20.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var addressTextFiled: UITextField!
    
    let videoClient = VideoClient()
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        guard let ipAddress = addressTextFiled.text else { return }
        
        do {
            try videoClient.connect(to: ipAddress, with: 12005)
            try videoClient.startSendingVideoToServer()
        } catch {
            print("error occured : \(error.localizedDescription)")
        }
    }
}

