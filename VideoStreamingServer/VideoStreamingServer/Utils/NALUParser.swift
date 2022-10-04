//
//  NALUParser.swift
//  TCPServerTest
//
//  Created by Jade on 2022/09/17.
//

import Foundation

/// Abstract: This Object receives NALU Stream and parse it to H264Format which
/// is composed of 4 bytes length data and NALU data
class NALUParser {
    
    /// Data stream received from the client.
    /// It'll be a seqeunce of NALU so we should pick out NALU from it.
    private var dataStream = Data()
    
    /// We should search data stream sequentially to pick out NALU of it.
    /// This is uesed for searching data stream.
    private var searchIndex = 0
    
    private lazy var parsingQueue = DispatchQueue.init(label: "parsing.queue",
                                                    qos: .userInteractive)
    
    /// callback when a NALU is seperated from data stream
    var h264UnitHandling: ((H264Unit) -> Void)?
    
    /// receives NALU stream data and parse it then call 'h264UnitHandling'
    func enqueue(_ data: Data) {
        parsingQueue.async { [unowned self] in
            dataStream.append(data)
            
            while searchIndex < dataStream.endIndex-3 {
                // examine if dataStream[searchIndex...searchIndex+3] is start code(0001)
                if (dataStream[searchIndex] | dataStream[searchIndex+1] |
                    dataStream[searchIndex+2] | dataStream[searchIndex+3]) == 1 {
                    // if searchIndex is zero, that means there's nothing to extract cause
                    // we only care left side of searchIndex
                    if searchIndex != 0 {
                        let h264Unit = H264Unit(payload: dataStream[0..<searchIndex])
                        h264UnitHandling?(h264Unit)
                    }
                    
                    // We excute O(n) complexity operation here which is terribly inefficent.
                    // I hope you to refactor this part with more efficent way like a circular buffer.
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
