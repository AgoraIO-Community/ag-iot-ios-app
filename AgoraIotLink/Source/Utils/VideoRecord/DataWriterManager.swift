//
//  DataWriterManager.swift
//  VideoCaptureDemo
//
//  Created by Avazu Holding on 2018/12/26.
//  Copyright © 2018 Avazu Holding. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AssetsLibrary
import Photos

enum RecordState: NSInteger {
	case initing
	case prepare
	case recording
	case finish
	case failed
}
@objc protocol DataWriterManagerDelegate: NSObjectProtocol {
	func finishWriting()
	func updateWritingProgress(progress: CGFloat)
}

@objc
public class DataWriterManager: NSObject {

	private var videoUrl: URL!
	private var writeQueue: DispatchQueue = DispatchQueue.init(label: "com.dotc.wdManager")
	
	lazy private var assetWriter: AVAssetWriter? = {
		return try? AVAssetWriter.init(url: videoUrl, fileType: AVFileType.mp4)
	}()
	private var assetWriterVideoInput: AVAssetWriterInput?
	private var assetWriterAudioInput: AVAssetWriterInput?
    private var adatptor: AVAssetWriterInputPixelBufferAdaptor?
	
	private var videoCompressionSetting: [String:Any]?
	private var audioCompressionSetting: [String:Any]?
	
    var videoW : CGFloat = 0
    var videoH : CGFloat = 0
    
	private var timer: Timer?
	private var recordTime: CGFloat = 0
	private var isCanWrite: Bool = false
    private var timescaleValue : Int32 = 25 //创建CMTime 使用，每秒多少帧 x86模拟器是25，真机为15 千从为25
    
    
	@objc init(url: URL?) {
        super.init()
	}
	private let lock = NSLock()
	//MARK: ----public
	var writeState: RecordState = .initing
	var outputSize: CGSize = CGSize.zero
	weak var delegate: DataWriterManagerDelegate?
	var videoFormatDesc: CMFormatDescription?
	var audioFormatDesc: CMFormatDescription?
    
	@objc func startWrite() {
		writeState = .recording
		setUpWriter()
	}
    
    func getTempVideoUrl() -> URL {
        let videoName = String.init(format: "test%@.mp4", UUID().uuidString)
        let videoPath = NSString(string: recordVideoFolder).appendingPathComponent(videoName) as String

        return  URL.init(fileURLWithPath: videoPath)
    }
    //MARK: ----- property
    var recordVideoFolder: String {
        if let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first {
            let direc = NSString(string: path).appendingPathComponent("fileoutVideo") as String
            if !FileManager.default.fileExists(atPath: direc) {
                try? FileManager.default.createDirectory(atPath: direc, withIntermediateDirectories: true, attributes: [:])
            }
            return direc
        }
        return ""
    }
    
	@objc func stopWrite() {
        
		writeState = .finish
		timer?.invalidate()
		timer = nil
 
		if assetWriter != nil && assetWriter?.status == AVAssetWriter.Status.writing {
			writeQueue.async {[weak self] in
				
				guard let strongSelf = self else {
					return
				}
				strongSelf.assetWriter?.finishWriting {
					//写入系统相册
					PHPhotoLibrary.shared().performChanges({
						PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: strongSelf.videoUrl)
					}, completionHandler: { (isSuccess, error) in
						if isSuccess {
							print("save successed")
						}
                        if error != nil {
                            print("写入相册失败:\(String(describing: error))")
                        }
					})
				}
			}
		}
	}


    @objc func appendSampleBuffer(sampleBuffer: CVPixelBuffer?,audioBuffer: CMSampleBuffer?,mediaType: AVMediaType,index:Int) {

        if lock.try() {
            if writeState.rawValue < RecordState.recording.rawValue {
                print("not ready yet")
                lock.unlock()
                return
            }
            lock.unlock()
        }
        
        writeQueue.async {[weak self] in
            guard let strongSelf = self else {
                return
            }
            autoreleasepool{
                if strongSelf.lock.try() {
                    if strongSelf.writeState.rawValue > RecordState.recording.rawValue {
                        print("recordstate finished or failed")
                        strongSelf.lock.unlock()
                        return
                    }
                    strongSelf.lock.unlock()
                }
                
                if !strongSelf.isCanWrite && mediaType == AVMediaType.video {
                    strongSelf.assetWriter?.startWriting()
                    strongSelf.assetWriter?.startSession(atSourceTime: CMTime.zero)
//                    strongSelf.assetWriter?.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
                    strongSelf.isCanWrite = true
                }
                if strongSelf.timer != nil {
                    DispatchQueue.main.async {
                        strongSelf.timer = Timer.init(timeInterval: 0.05, target: strongSelf, selector: #selector(strongSelf.updateProgress), userInfo: nil, repeats: true)
                        
                    }
                }
                //开始写入视频
                if mediaType == AVMediaType.video && strongSelf.assetWriterVideoInput != nil {
                    if strongSelf.assetWriterVideoInput!.isReadyForMoreMediaData {
                        let flag = strongSelf.adatptor!.append(sampleBuffer!, withPresentationTime: CMTimeMake(value: Int64(index), timescale: strongSelf.timescaleValue))
//                        let flag = strongSelf.assetWriterVideoInput!.append(sampleBuffer)
                        print("video record")
                        if !flag {
                            print("video record failed")
                            if strongSelf.lock.try() {
                                strongSelf.stopWrite()
                                strongSelf.destroyWriter()
                                strongSelf.lock.unlock()
                            }
                        }
                    }
                }
                //audio
                if mediaType == AVMediaType.audio && strongSelf.assetWriterAudioInput != nil {
                    if strongSelf.assetWriterAudioInput!.isReadyForMoreMediaData {
                        let flag = strongSelf.assetWriterAudioInput!.append(audioBuffer!)
                        print("audio record")
                        if !flag {
                            print("audio record failed")
                            if strongSelf.lock.try() {
                                strongSelf.stopWrite()
                                strongSelf.destroyWriter()
                                strongSelf.lock.unlock()
                            }
                        }
                    }
                }
            }
        }
        
    }
    
//	@objc func appendSampleBuffer(sampleBuffer: CMSampleBuffer,mediaType: AVMediaType) {
//
//		if lock.try() {
//			if writeState.rawValue < RecordState.recording.rawValue {
//				print("not ready yet")
//				lock.unlock()
//				return
//			}
//			lock.unlock()
//		}
//
//		writeQueue.async {[weak self] in
//			guard let strongSelf = self else {
//				return
//			}
//			autoreleasepool{
//				if strongSelf.lock.try() {
//					if strongSelf.writeState.rawValue > RecordState.recording.rawValue {
//						print("recordstate finished or failed")
//						strongSelf.lock.unlock()
//						return
//					}
//					strongSelf.lock.unlock()
//				}
//
//				if !strongSelf.isCanWrite && mediaType == AVMediaType.video {
//					strongSelf.assetWriter?.startWriting()
//					strongSelf.assetWriter?.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
//					strongSelf.isCanWrite = true
//				}
//				if strongSelf.timer != nil {
//					DispatchQueue.main.async {
//						strongSelf.timer = Timer.init(timeInterval: 0.05, target: strongSelf, selector: #selector(strongSelf.updateProgress), userInfo: nil, repeats: true)
//
//					}
//				}
//				//开始写入视频
//				if mediaType == AVMediaType.video && strongSelf.assetWriterVideoInput != nil {
//					if strongSelf.assetWriterVideoInput!.isReadyForMoreMediaData {
//						let flag = strongSelf.assetWriterVideoInput!.append(sampleBuffer)
//						if !flag {
//							print("video record failed")
//							if strongSelf.lock.try() {
//								strongSelf.stopWrite()
//								strongSelf.destroyWriter()
//								strongSelf.lock.unlock()
//							}
//						}
//					}
//				}
//				//audio
//				if mediaType == AVMediaType.audio && strongSelf.assetWriterAudioInput != nil {
//					if strongSelf.assetWriterAudioInput!.isReadyForMoreMediaData {
//						let flag = strongSelf.assetWriterAudioInput!.append(sampleBuffer)
//						if !flag {
//							print("video record failed")
//							if strongSelf.lock.try() {
//								strongSelf.stopWrite()
//								strongSelf.destroyWriter()
//								strongSelf.lock.unlock()
//							}
//						}
//					}
//				}
//			}
//		}
//
//	}
    
    
	@objc private func updateProgress() {
		if  recordTime >= 8.0 {
			stopWrite()
			
			if delegate != nil {
				delegate!.finishWriting()
			}
			return
		}
		recordTime += 0.05
		if delegate != nil  {
			delegate!.updateWritingProgress(progress: recordTime/8.0)
		}
	}
	private func setUpWriter() {
		
        videoUrl = getTempVideoUrl()
        outputSize = CGSize.init(width: videoW, height: videoH)
        debugPrint("--outputSize--%@---%@",videoW,videoH)
        
        
        // 获取当前屏幕的最佳分辨率
        guard let screenSize = UIScreen.main.currentMode?.size else{
            return
        }
          
        let wScale = screenSize.width / (outputSize.width)
        outputSize.width = screenSize.width
        outputSize.height = wScale * outputSize.height
        
        debugPrint("---mWScale---%@",wScale)
        debugPrint("---screenSize---%@",screenSize)
        debugPrint("--outputSize_New--%@",outputSize)
        
		//写入视频大小
		let numPixels: NSInteger = NSInteger(outputSize.width * outputSize.height)
		//每像素比特
		let bitsPerPixel: CGFloat = 3.0 //原为6，可设置为12更清晰，输出视频大小也是现在的3倍
        //视频尺寸*比率，10.1相当于AVCaptureSessionPresetHigh，数值越大，显示越精细
		let bitsPerSecond: NSInteger = numPixels * NSInteger(bitsPerPixel)
		
		//码率和帧率设置
		let compressionProperties = [AVVideoAverageBitRateKey : NSNumber.init(value: bitsPerSecond),
									 AVVideoExpectedSourceFrameRateKey : (30 as NSNumber),
									 AVVideoMaxKeyFrameIntervalKey : NSNumber.init(value:30),//关键帧最大间隔 数值越大压缩率越高（只支持H.264）
									 AVVideoProfileLevelKey : AVVideoProfileLevelH264BaselineAutoLevel] as [String : Any]//画质级别
		
        videoCompressionSetting = [AVVideoCodecKey : AVVideoCodecType.h264,
								   AVVideoScalingModeKey : AVVideoScalingModeResizeAspectFill,
								   AVVideoWidthKey : NSNumber.init(value: Int(outputSize.width)),
								   AVVideoHeightKey : NSNumber.init(value: Int(outputSize.height)),
								   AVVideoCompressionPropertiesKey : compressionProperties]
		
		assetWriterVideoInput = AVAssetWriterInput.init(mediaType: .video, outputSettings: videoCompressionSetting)
		
		//expectsMediaDataInRealTime 必须设为yes，需要从capture session 实时获取数据
		assetWriterVideoInput?.expectsMediaDataInRealTime = true
//		assetWriterVideoInput?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2.0))
//        assetWriterVideoInput?.transform = fixTransform(deviceOrientation: UIDevice.current.orientation)
        
        adatptor = AVAssetWriterInputPixelBufferAdaptor.init(assetWriterInput: assetWriterVideoInput! ,sourcePixelBufferAttributes: nil)
        
		//音频设置
		audioCompressionSetting = [AVEncoderBitRatePerChannelKey : NSNumber.init(value: 44100),//AVEncoderBitRatePerChannelKey
								   AVFormatIDKey : NSNumber.init(value: kAudioFormatMPEG4AAC),
								   AVNumberOfChannelsKey : NSNumber.init(value: 2),//通道数 通常为双声道 值2
								   AVSampleRateKey : NSNumber.init(value: 44100)]//
		assetWriterAudioInput = AVAssetWriterInput.init(mediaType: AVMediaType.audio, outputSettings: audioCompressionSetting)
		assetWriterAudioInput?.expectsMediaDataInRealTime = true
		
		if assetWriter != nil {
			if assetWriter!.canAdd(assetWriterVideoInput!) {
				assetWriter!.add(assetWriterVideoInput!)
			}
			if assetWriter!.canAdd(assetWriterAudioInput!) {
				assetWriter!.add(assetWriterAudioInput!)
			}
		}
		writeState = .recording
        debugPrint("setUpWriter：")
	}
	
	deinit {
		destroyWriter()
	}
	func destroyWriter() {
        debugPrint("destroyWriter：")
		assetWriter = nil
		assetWriterVideoInput = nil
		assetWriterAudioInput = nil
		recordTime = 0
		timer?.invalidate()
		timer = nil
	}
    
    private func fixTransform(deviceOrientation: UIDeviceOrientation) -> CGAffineTransform {
        let orientation = deviceOrientation == .unknown ? .portrait : deviceOrientation
        var result: CGAffineTransform
        
        switch orientation {
        case .landscapeRight:
            result = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        case .portraitUpsideDown:
            result = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2 * 3))
        case .portrait,.faceUp,.faceDown:
            result = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        default:
            result = CGAffineTransform.identity
        }
        return result;
    }
}
