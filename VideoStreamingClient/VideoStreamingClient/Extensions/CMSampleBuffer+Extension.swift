//
//  CMSampleBuffer+Extension.swift
//  CameraTest
//
//  Created by Jade on 2022/09/19.
//

import AVFoundation

extension CMSampleBuffer {
    var isKeyFrame: Bool {
        let attachments =  CMSampleBufferGetSampleAttachmentsArray(self, createIfNecessary: true) as? [[CFString: Any]]
        
        let isNotKeyFrame = (attachments?.first?[kCMSampleAttachmentKey_NotSync] as? Bool) ?? false
        
        return !isNotKeyFrame
    }
}
