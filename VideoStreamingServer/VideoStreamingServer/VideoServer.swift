//
//  Base.swift
//  TCPServerTest
//
//  Created by Jade on 2022/09/17.
//

import Foundation
import CoreMedia

class VideoServer {
    
    // MARK: - dependencies
    
    private let server = TCPServer()
    private let naluParser = NALUParser()
    private let h264Converter = H264Converter()
    
    // MARK: - init
    
    init() {
        setServerDataHandling()
        setNALUParserHandling()
    }
    
    // MARK: - task methods
    
    func start(on port: UInt16) throws {
        try server.start(on: port)
    }
    
    func setSampleBufferCallback(_ callback: @escaping (CMSampleBuffer) -> Void) {
        h264Converter.callback = callback
    }
    
    // MARK: - helper methods
    
    private func setServerDataHandling() {
        server.recievedDataHandling = { [naluParser] data in
            naluParser.enqueue(data)
        }
    }
    
    private func setNALUParserHandling() {
        naluParser.naluHandling = { [h264Converter] h264Unit in
            h264Converter.convert(h264Unit)
        }
    }
}
