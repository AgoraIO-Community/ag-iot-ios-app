//
//  VideoRecordManager.swift
//  AgoraIotLink
//
//  Created by admin on 2022/12/9.
//

import UIKit
import AgoraRtcKit
import AVFoundation

class VideoRecordManager: NSObject {

    var index : Int = 0
    var indexAudio : Int64 = 0
    
    var isFirstAudioBuffer : Bool = true
    var remoteAudio : Int64 = 0
    var videoW : Int32 = 0
    var videoH : Int32 = 0
    
    var documentPath : String = ""
    
    var writeManager : DataWriterManager?
    
    func startWriter(){
        
        writeManager = DataWriterManager.init(url: nil)
        writeManager?.videoW = CGFloat(videoW)
        writeManager?.videoH = CGFloat(videoH)
        writeManager?.documentPath = documentPath
        index = 0
        indexAudio = 0
        writeManager?.startWrite()
    }
    
    func stopWriter(){
        writeManager?.stopWrite()
    }
 
    func videoWithSampleBuffer(_ buffer : CVPixelBuffer){
        
        index += 1
//        print("index:\(index)")
        writeManager?.appendSampleBuffer(sampleBuffer: buffer, audioBuffer: nil, mediaType: .video,index: index)
        
//        let factory = CMSampleBuffer.Factory()
//        let sampleBuffer = factory.createSampleBuffer(pixelBuffer: buffer)
//        print("videoWithSampleBuffer:\(sampleBuffer)")
 
    }
    
    func audioWithBuffer( _ frame: AgoraAudioFrame){
        
        //10位数时间戳
//        let nowDate1: Int = Int(Date().timeIntervalSince1970)
//        if isFirstAudioBuffer == true{
//            isFirstAudioBuffer = false
//            remoteAudio = frame.renderTimeMs
//        }
//        indexAudio = frame.renderTimeMs - remoteAudio
        indexAudio += 1
        let sampleBuffer = createSilentAudio(startFrm: indexAudio, sampleCount: frame.samplesPerChannel, sampleRate: Float64(frame.samplesPerSec) , numChannels: UInt32(frame.channels), buffer: frame.buffer!)
        writeManager?.appendSampleBuffer(sampleBuffer: nil, audioBuffer: sampleBuffer, mediaType: .audio,index: Int(indexAudio))
        
    }
    
}

//视频帧RTC 推流视频帧为 24fps  mp4视频帧设置15fps  rtc 设置采样率44100，此处 mSampleRate 和 CMtime 设置为26000
extension VideoRecordManager{
    
    func createSilentAudio(startFrm: Int64, sampleCount: Int, sampleRate: Float64, numChannels: UInt32, buffer:UnsafeRawPointer) -> CMSampleBuffer? {
        let bytesPerFrame = UInt32(2 * numChannels)
        let blockSize = sampleCount*Int(bytesPerFrame)

        var block: CMBlockBuffer?
        var status = CMBlockBufferCreateWithMemoryBlock(
            allocator: kCFAllocatorDefault,
            memoryBlock: nil,
            blockLength: blockSize,  // blockLength
            blockAllocator: nil,        // blockAllocator
            customBlockSource: nil,        // customBlockSource
            offsetToData: 0,          // offsetToData
            dataLength: blockSize,  // dataLength
            flags: 0,          // flags
            blockBufferOut: &block
        )
        assert(status == kCMBlockBufferNoErr)

        // we seem to get zeros from the above, but I can't find it documented. so... memset:
        status = CMBlockBufferReplaceDataBytes(with: buffer, blockBuffer: block!, offsetIntoDestination: 0, dataLength: blockSize)
//        status = CMBlockBufferFillDataBytes(with: 0, blockBuffer: block!, offsetIntoDestination: 0, dataLength: blockSize)
        
        assert(status == kCMBlockBufferNoErr)

        var asbd = AudioStreamBasicDescription(
            mSampleRate: sampleRate, //采样率
            mFormatID: kAudioFormatLinearPCM, //编码格式
            mFormatFlags: kLinearPCMFormatFlagIsSignedInteger, //数据格式
            mBytesPerPacket: bytesPerFrame, //每个Packet的Bytes数
            mFramesPerPacket: 1, //每个Packet的帧数
            mBytesPerFrame: bytesPerFrame,
            mChannelsPerFrame: numChannels,
            mBitsPerChannel: 16,
            mReserved: 0
        )

        var formatDesc: CMAudioFormatDescription?
        status = CMAudioFormatDescriptionCreate(allocator: kCFAllocatorDefault, asbd: &asbd, layoutSize: 0, layout: nil, magicCookieSize: 0, magicCookie: nil, extensions: nil, formatDescriptionOut: &formatDesc)
        assert(status == noErr)

        var sampleBuffer: CMSampleBuffer?

        // born ready
        status = CMAudioSampleBufferCreateReadyWithPacketDescriptions(
            allocator: kCFAllocatorDefault,
            dataBuffer: block!,      // dataBuffer
            formatDescription: formatDesc!,
            sampleCount: sampleCount,    // numSamples
            presentationTimeStamp: CMTimeMake(value: startFrm, timescale: Int32(sampleRate)),    // sbufPTS
            packetDescriptions: nil,        // packetDescriptions
            sampleBufferOut: &sampleBuffer
        )
        assert(status == noErr)
        
        return sampleBuffer
    }
    
    //暂时无用
    func createSampleBufferWith(pixelBuffer: CVPixelBuffer) -> CMSampleBuffer {
        var info = CMSampleTimingInfo()
        info.presentationTimeStamp = .zero
        info.duration = .invalid
        info.decodeTimeStamp = .invalid
        var formatDesc: CMFormatDescription? = nil
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: pixelBuffer, formatDescriptionOut: &formatDesc)
        guard let formatDescription = formatDesc else {
            fatalError("formatDescription")
        }
        var sampleBuff: CMSampleBuffer? = nil
        let status = CMSampleBufferCreateReadyWithImageBuffer(allocator: kCFAllocatorDefault,
                                                 imageBuffer: pixelBuffer,
                                                 formatDescription: formatDescription,
                                                 sampleTiming: &info,
                                                 sampleBufferOut: &sampleBuff)
        
        guard status == noErr else {
            fatalError("CMSampleBufferCreateReadyWithImageBuffer failed \(status)")
        }
        guard let sampleBuffer = sampleBuff else {
            fatalError("samplebuffer")
        }
        return sampleBuffer
    }
    
}


