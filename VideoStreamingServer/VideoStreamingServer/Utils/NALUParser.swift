//
//  NALUParser.swift
//  TCPServerTest
//
//  Created by Jade on 2022/09/17.
//

import Foundation

/// This Object receives NALU Stream and parse it to H264Format which
/// is composed of 4 bytes length data and NALU data
class NALUParser {
    
    private var dataStream = Data()
    private var searchIndex = 0
    
    private lazy var taskQueue = DispatchQueue.init(label: "parser.queue",
                                                    qos: .userInteractive)
    var naluHandling: ((H264Unit) -> Void)?
    
    func enqueue(_ data: Data) {
        taskQueue.async { [self] in
            dataStream.append(data)
            
            while searchIndex < dataStream.endIndex-3 {
                if (dataStream[searchIndex] | dataStream[searchIndex+1] |
                    dataStream[searchIndex+2] | dataStream[searchIndex+3]) == 1 {
                    if searchIndex != 0 {
                        let h264Unit = H264Unit(payload: dataStream[0..<searchIndex])
                        naluHandling?(h264Unit)
                    }
                    
                    dataStream.removeSubrange(0...searchIndex+3)
                    searchIndex = 0
                } else if dataStream[searchIndex+3] != 0 {
                    searchIndex += 4
                } else { // dataStream[searchIndex+3] == 0
                    searchIndex += 1
                }
            }
        }
    }
}
