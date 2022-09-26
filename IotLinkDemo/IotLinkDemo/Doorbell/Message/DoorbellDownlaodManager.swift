//
//  DoorbellDownlaodManager.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/30.
//

import Foundation
import SVProgressHUD
import Alamofire
import SJVideoPlayer
import AgoraIotLink

class DownloadInfo : Equatable {
    static func == (lhs: DownloadInfo, rhs: DownloadInfo) -> Bool {
        return lhs.url == rhs.url
    }
    
    var url: URL?
    var request: DownloadRequest?
    var progress:Float = 0.0
    var isCanceled = false
}

class DoorbellDownlaodManager: NSObject {
    
    static let shared = DoorbellDownlaodManager()

    private var requests: [URL: DownloadInfo] = [URL: DownloadInfo]()
    
    private (set) var downloadInfoArray:[DownloadInfo] = [DownloadInfo]()

    // 下载
    func download(player:SJVideoPlayer,url: URL, start:(()->Void)? = nil, completion:@escaping(Bool,String)->Void){
        start?()
        let info = DownloadInfo()
        info.url = url
        
        var fileName = url.absoluteString;
        guard let rearMark = fileName.lastIndex(of: "."),
              let startMark = fileName.lastIndex(of: "/") else {
              log.e("demo url error for download:\(fileName)")
              completion(false,"解析视频信息错误")
              return
        }
        
        let name = String(fileName[fileName.index(after: startMark)...fileName.index(before: rearMark)])
        let mediaName = name + ".mp4"
        
        var dir = URL.init(string:NSHomeDirectory())
        var path = dir?.appendingPathComponent("Documents").appendingPathComponent(mediaName)
        
        guard let path = path else{
            log.e("demo path to download video is nil")
            completion(false,"保存视频路径错误")
            return
        }
        
        let commandStr:String = "ffmpeg -loglevel repeat+level+warning -i \(fileName) -y \(path.absoluteString)"
        
        //log.i("demo \(commandStr)")
        player.ffmpegMain(commandStr, completionBlock: {ec,msg in
            if(ec == 0){
                UISaveVideoAtPathToSavedPhotosAlbum(path.absoluteString, self, #selector(self.didFinishSavingVideo(videoPath:error:contextInfo:)), nil);
                completion(true,msg)
            }
            else if(ec < 0){
                log.e("demo download video failed:\(msg)(\(ec))")
                completion(false,msg)
            }
            else{
                log.i("progressing \(msg)(\(ec))")
            }
        })
//        let request = AF.download(url).downloadProgress{ progress in
//            debugPrint("下载进度：\(progress.fractionCompleted)")
//            info.progress = Float(progress.fractionCompleted)
//        }.responseData {response in
//            completion?()
//            if response.error == nil, let filePath = response.fileURL {
//                let cacheFile:String = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last ?? ""
//                var url = URL(fileURLWithPath: cacheFile)
//                url.appendPathComponent("\(filePath.lastPathComponent)")
//                url.appendPathExtension("mp4")
//                try?FileManager.default.moveItem(at: filePath, to: url)
//                if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path) {
//                    UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, #selector(self.didFinishSavingVideo(videoPath:error:contextInfo:)), nil)
//                }
//            }
//        }
//        info.request = request
        if requests[url] == nil {
            requests[url] = info
            downloadInfoArray.append(info)
        }
    }
    
    // 保存结果
    @objc func didFinishSavingVideo(videoPath: String, error: NSError?, contextInfo: UnsafeMutableRawPointer?) {
        DispatchQueue.main.async {
            if error != nil{
                SVProgressHUD.showError(withStatus: "保存失败")
            }else{
                SVProgressHUD.showSuccess(withStatus: "保存成功，请到相册中查看")
            }
        }
    }
    
    // 取消下载
    func cancelDownload(url:URL?) {
        if url == nil {
            return
        }
        let info = requests[url!]
        info?.request?.cancel()
        info?.isCanceled = true
        requests[url!] = nil
        guard let info = info else{
            return
        }
        if let idx = downloadInfoArray.index(of: info){
            downloadInfoArray.remove(at: idx)
        }
    }
}
