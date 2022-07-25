//
//  DoorbellDownlaodManager.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/30.
//

import Foundation
import SVProgressHUD
import Alamofire

class DownloadInfo {
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
    func download(url: URL, start:(()->Void)? = nil, completion:(()->Void)? = nil){
        start?()
        let info = DownloadInfo()
        info.url = url
        let request = AF.download(url).downloadProgress{ progress in
            debugPrint("下载进度：\(progress.fractionCompleted)")
            info.progress = Float(progress.fractionCompleted)
        }.responseData {response in
            completion?()
            if response.error == nil, let filePath = response.fileURL {
                let cacheFile:String = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last ?? ""
                var url = URL(fileURLWithPath: cacheFile)
                url.appendPathComponent("\(filePath.lastPathComponent)")
                url.appendPathExtension("mp4")
                try?FileManager.default.moveItem(at: filePath, to: url)
                if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path) {
                    UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, #selector(self.didFinishSavingVideo(videoPath:error:contextInfo:)), nil)
                }
            }
        }
        info.request = request
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
    }
}
