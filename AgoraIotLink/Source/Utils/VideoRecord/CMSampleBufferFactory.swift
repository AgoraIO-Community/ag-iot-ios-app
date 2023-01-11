
import AVFoundation


extension CMSampleBuffer {
    public class Factory {
        public let audio = AudioFactory()
        public let video = VideoFactory()
        
        init() {
        }
        public func createSampleBufferBy(pcm: [Float]) -> CMSampleBuffer? {
            return audio.createSampleBufferBy(pcm: pcm)
        }
        public func createSampleBufferBy(mtlTexture: MTLTexture) -> CMSampleBuffer? {
            return video.createSampleBufferBy(mtlTexture: mtlTexture)
        }
        public func createSampleBuffer(pixelBuffer: CVPixelBuffer) -> CMSampleBuffer? {
            return video.createSampleBuffer(pixelBuffer: pixelBuffer)
        }
    }
}

extension CMSampleBuffer {
    public class AudioFactory {
        private var formatDescription: CMAudioFormatDescription!
        
        init() {
            var basicDescription = AudioStreamBasicDescription(mSampleRate: 44100,
                                                               mFormatID: kAudioFormatLinearPCM,
                                                               mFormatFlags: kLinearPCMFormatFlagIsFloat,
                                                               mBytesPerPacket: 4,
                                                               mFramesPerPacket: 1,
                                                               mBytesPerFrame: 4,
                                                               mChannelsPerFrame: 1,
                                                               mBitsPerChannel: 32,
                                                               mReserved: 0)
            var tmpDescription: CMAudioFormatDescription?
            let status = CMAudioFormatDescriptionCreate(allocator: kCFAllocatorDefault,
                                                        asbd: &basicDescription,
                                                        layoutSize: 0,
                                                        layout: nil,
                                                        magicCookieSize: 0,
                                                        magicCookie: nil,
                                                        extensions: nil,
                                                        formatDescriptionOut: &tmpDescription)
            if status != noErr {
                print("failed create cmsamplebuffer audio factory@1")
            }
            guard let outDescription = tmpDescription else {
                print("failed create cmsamplebuffer audio factory@2")
                return
            }
            formatDescription = outDescription
        }
        
        public func createSampleBufferBy(pcm: [Float]) -> CMSampleBuffer? {
            var blockBuffer: CMBlockBuffer?
            _ = CMBlockBufferCreateWithMemoryBlock(allocator: kCFAllocatorDefault,
                                                   memoryBlock: UnsafeMutableRawPointer(mutating: pcm),
                                                   blockLength: pcm.count * MemoryLayout<Float>.stride,
                                                   blockAllocator: kCFAllocatorNull,
                                                   customBlockSource: nil,
                                                   offsetToData: 0,
                                                   dataLength: pcm.count * MemoryLayout<Float>.stride,
                                                   flags: 0,
                                                   blockBufferOut: &blockBuffer)
            var sampleBuffer: CMSampleBuffer?
            let timestamp = CMTime(value: CMTimeValue(Int(Date().timeIntervalSince1970 * 30000.0)),
                                   timescale: 30000,
                                   flags: .init(rawValue: 3),
                                   epoch: 0)
            _ = CMAudioSampleBufferCreateWithPacketDescriptions(allocator: kCFAllocatorDefault,
                                                                dataBuffer: blockBuffer,
                                                                dataReady: true,
                                                                makeDataReadyCallback: nil,
                                                                refcon: nil,
                                                                formatDescription: formatDescription,
                                                                sampleCount: pcm.count,
                                                                presentationTimeStamp: timestamp,
                                                                packetDescriptions: nil,
                                                                sampleBufferOut: &sampleBuffer)
            return sampleBuffer
        }
    }
}

extension CMSampleBuffer {
    public class VideoFactory {
        private let context = CIContext()
        
        init() {
        }
        
        private func createPixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
            var pixelBuffer: CVPixelBuffer?
            let status = CVPixelBufferCreate(nil,
                                             width,
                                             height,
                                             kCVPixelFormatType_32BGRA,
                                             nil,
                                             &pixelBuffer)
            if status != kCVReturnSuccess {
                return nil
            }
            return pixelBuffer
        }
        
        public func createSampleBufferBy(mtlTexture: MTLTexture) -> CMSampleBuffer? {
            guard let pixelBuffer = self.createPixelBuffer(width: mtlTexture.width, height: mtlTexture.height) else {
                return nil
            }
            CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
            let ci = CIImage(mtlTexture: mtlTexture, options: nil)!
            context.render(ci, to: pixelBuffer)
            var opDescription: CMVideoFormatDescription?
            var status =
                CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault,
                                                             imageBuffer: pixelBuffer,
                                                             formatDescriptionOut: &opDescription)
            if status != noErr {
                return nil
            }
            guard let description: CMVideoFormatDescription = opDescription else {
                return nil
            }
            var sampleBuffer: CMSampleBuffer?
            var sampleTiming = CMSampleTimingInfo()
            sampleTiming.presentationTimeStamp = CMTime(value: CMTimeValue(Int(Date().timeIntervalSince1970 * 30000.0)),
                                                        timescale: 30000,
                                                        flags: .init(rawValue: 3),
                                                        epoch: 0)
            status = CMSampleBufferCreateForImageBuffer(allocator: kCFAllocatorDefault,
                                                        imageBuffer: pixelBuffer,
                                                        dataReady: true,
                                                        makeDataReadyCallback: nil,
                                                        refcon: nil,
                                                        formatDescription: description,
                                                        sampleTiming: &sampleTiming,
                                                        sampleBufferOut: &sampleBuffer)
            CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
            return sampleBuffer
        }
        
        public func createSampleBuffer(pixelBuffer: CVPixelBuffer) -> CMSampleBuffer? {

           
            CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
            
            var opDescription: CMVideoFormatDescription?
            var status =
                CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault,
                                                             imageBuffer: pixelBuffer,
                                                             formatDescriptionOut: &opDescription)
            if status != noErr {
                return nil
            }
            guard let description: CMVideoFormatDescription = opDescription else {
                return nil
            }
            var sampleBuffer: CMSampleBuffer?
            var sampleTiming = CMSampleTimingInfo()
            sampleTiming.presentationTimeStamp = CMTime(value: CMTimeValue(Int(Date().timeIntervalSince1970 * 30000.0)),
                                                        timescale: 30000,
                                                        flags: .init(rawValue: 3),
                                                        epoch: 0)
            status = CMSampleBufferCreateForImageBuffer(allocator: kCFAllocatorDefault,
                                                        imageBuffer: pixelBuffer,
                                                        dataReady: true,
                                                        makeDataReadyCallback: nil,
                                                        refcon: nil,
                                                        formatDescription: description,
                                                        sampleTiming: &sampleTiming,
                                                        sampleBufferOut: &sampleBuffer)
            
            CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
            
            return sampleBuffer
        }
    }
}


