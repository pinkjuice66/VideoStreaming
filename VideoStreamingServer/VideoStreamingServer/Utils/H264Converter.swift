//
//  CMSampleBufferCreater.swift
//  TCPServerTest
//
//  Created by Jade on 2022/09/18.
//

import Foundation
import AVFoundation

/// Abstract: This object receives H264 Unit and convert it to CMSampleBuffer
///
/// This dose not excute decoding operation. So it just converts H264Unit to
/// 'encoded' CMSampleBuffer
class H264Converter {
    
    // MARK: - properties
    
    private var sps: H264Unit?
    private var pps: H264Unit?
    
    private var description: CMVideoFormatDescription?
    
    var sampleBufferCallback: ((CMSampleBuffer) -> Void)?
    
    // MARK: - task method
    
    func convert(_ h264Unit: H264Unit) {
        if h264Unit.type == .sps || h264Unit.type == .pps {
            description = nil
            createDescription(with: h264Unit)
            return
        } else {
            sps = nil
            pps = nil
        }

        guard let blockBuffer = createBlockBuffer(with: h264Unit),
              let sampleBuffer = createSampleBuffer(with: blockBuffer) else {
            return
        }
        
        sampleBufferCallback?(sampleBuffer)
    }
    
    // MARK: - helper mehtods
    
    private func createSampleBuffer(with blockBuffer: CMBlockBuffer) -> CMSampleBuffer? {
        var sampleBuffer : CMSampleBuffer?
        var timingInfo = CMSampleTimingInfo()
        timingInfo.decodeTimeStamp = .invalid
        timingInfo.duration = CMTime.invalid
        timingInfo.presentationTimeStamp = .zero
        
        let error = CMSampleBufferCreateReady(allocator: kCFAllocatorDefault,
                                  dataBuffer: blockBuffer,
                                  formatDescription: description,
                                  sampleCount: 1,
                                  sampleTimingEntryCount: 1,
                                  sampleTimingArray: &timingInfo,
                                  sampleSizeEntryCount: 0,
                                  sampleSizeArray: nil,
                                  sampleBufferOut: &sampleBuffer)
        
        guard error == noErr,
              let sampleBuffer = sampleBuffer else {
            print("fail to create sample buffer")
            return nil
        }
        
        if let attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer,
                                                                     createIfNecessary: true) {
            let dic = unsafeBitCast(CFArrayGetValueAtIndex(attachments, 0),
                                    to: CFMutableDictionary.self)
            
            CFDictionarySetValue(dic,
                                 Unmanaged.passUnretained(kCMSampleAttachmentKey_DisplayImmediately).toOpaque(),
                                 Unmanaged.passUnretained(kCFBooleanTrue).toOpaque())
        }
        
        return sampleBuffer
    }
    
    private func createBlockBuffer(with h264Format: H264Unit) -> CMBlockBuffer? {
        let pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: h264Format.data.count)
        
        h264Format.data.copyBytes(to: pointer, count: h264Format.data.count)
        var blockBuffer: CMBlockBuffer?
        
        let error = CMBlockBufferCreateWithMemoryBlock(allocator: kCFAllocatorDefault,
                                                       memoryBlock: pointer,
                                                       blockLength: h264Format.data.count,
                                                       blockAllocator: kCFAllocatorDefault,
                                                       customBlockSource: nil,
                                                       offsetToData: 0,
                                                       dataLength: h264Format.data.count,
                                                       flags: .zero,
                                                       blockBufferOut: &blockBuffer)
        
        guard error == kCMBlockBufferNoErr else {
            print("fail to create block buffer")
            return nil
        }
        
        return blockBuffer
    }
    
    private func createDescription(with h264Format: H264Unit) {
        if h264Format.type == .sps {
            sps = h264Format
        } else if h264Format.type == .pps {
            pps = h264Format
        }
        
        guard let sps = sps,
              let pps = pps else {
            return
        }
        
        let spsPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: sps.data.count)
        sps.data.copyBytes(to: spsPointer, count: sps.data.count)
        
        let ppsPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: pps.data.count)
        pps.data.copyBytes(to: ppsPointer, count: pps.data.count)
                
        let parameterSet = [UnsafePointer(spsPointer), UnsafePointer(ppsPointer)]
        let parameterSetSizes = [sps.data.count, pps.data.count]
        
        defer {
            parameterSet.forEach {
                $0.deallocate()
            }
        }
                        
        CMVideoFormatDescriptionCreateFromH264ParameterSets(allocator: kCFAllocatorDefault,
                                                            parameterSetCount: 2,
                                                            parameterSetPointers: parameterSet,
                                                            parameterSetSizes: parameterSetSizes,
                                                            nalUnitHeaderLength: 4,
                                                            formatDescriptionOut: &description)
    }
}
