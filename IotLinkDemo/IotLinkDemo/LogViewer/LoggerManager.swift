//
//  DataProvider.swift
//  SwiftyLog
//
//  Created by Zhihui Tang on 2018-01-09.
//

import Foundation
import AgoraIotLink

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard Logger.shared.level != .none else { return }
        guard Logger.shared.ouput == .debugerConsoleAndFile
            || Logger.shared.ouput == .deviceConsoleAndFile
            || Logger.shared.ouput == .fileOnly else { return }
        
        //Logger.shared.saveAsync()
        let manager = LoggerManager()
        manager.show()
    }
}

protocol LoggerAction {
    func removeAll()
}

class LoggerManager: NSObject {
    let controller = LoggerViewController()
    public func show() {
        guard let topViewController = UIApplication.topViewController() else { return }
        guard topViewController .isKind(of: LoggerViewController.self) == false else { return }
        
        controller.data = " \(loadLog())\(deviceInfo())"
        controller.delegate = self
        
        topViewController.present(controller, animated: true, completion: nil)
    }
    
    // MARK: - Init
    private let fileExtension = "txt"
    private let isolationQueue = DispatchQueue(label: "com.crafttang.isolation", qos: .background, attributes: .concurrent)
    private let serialQueue = DispatchQueue(label: "com.crafttang.swiftylog")
    private let logSubdiretory = FileManager.documentDirectoryURL.appendingPathComponent("txt")
    
    private var logUrl: URL? {
        let fileName = "agoraiot"
        try? FileManager.default.createDirectory(at: logSubdiretory, withIntermediateDirectories: false)
        let url = logSubdiretory.appendingPathComponent(fileName).appendingPathExtension("txt")
        return url
    }
    
    private func load() -> [String]? {
        guard let url = logUrl else { return nil }
        guard let strings = try? String(contentsOf: url, encoding: String.Encoding.utf8) else { return nil }

        return strings.components(separatedBy: "\n")
    }
    
    private func loadLog() -> String {
        var texts: [String] = []
        
        guard let data = load() else { return "" }
        
        data.forEach { (string) in
            texts.append("<pre style=\"line-height:8px;\">\(string)</pre>")
        }
        
        return texts.joined()
    }
    
    private func deviceInfo() -> String {
        var texts:[String] = []
        
        texts.append("<pre style=\"line-height:8px;\">==============================================</pre>")
        LoggerHelper.info().forEach { (string) in
            texts.append("<pre style=\"line-height:8px;\">\(string)</pre>")
        }
        return texts.joined()
    }
}

extension LoggerManager: LoggerAction {
    func removeAll() {
        //Logger.shared.removeAllAsync()
        controller.data = deviceInfo()
    }
}
