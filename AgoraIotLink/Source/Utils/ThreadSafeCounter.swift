//
//  ThreadSafeCounter.swift
//  AgoraIotLink
//
//  Created by admin on 2023/7/10.
//

import Foundation

class ThreadSafeCounter {
    private var value: UInt32 = 1
    private let queue = DispatchQueue(label: "com.example.threadSafeCounterQueue")
    
    func increment() -> UInt32 {
        return queue.sync {
            value += 1
            return value
        }
    }
}
