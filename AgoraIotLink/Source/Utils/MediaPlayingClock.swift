//
//  MediaPlayingClock.swift
//  AgoraIotLink
//
//  Created by admin on 2023/8/25.
//

import Foundation

/**
 * @brief Media Playing Clock
 */
public class MediaPlayingClock {
    
    
    private var mIsRunning: Bool = false            ///< 当前时钟是否在运行
    private var mBeginTicks: TimeInterval = 0       ///< 时钟开始运行的时刻点
    private var mDuration: TimeInterval = 0         ///< 时钟前面总时长
    private var mRunSpeed: Int = 1                  ///< 时钟倍速，通常是 1,2,4
    
    private let semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    
    /**
     * @brief 播放器时钟从 当前进度 开始运行
     */
    public func start() {
        if mIsRunning == true {
            log.i("error:MediaPlayingClock is runing")
            return
        }
        semaphore.wait()
        mIsRunning = true
        mBeginTicks = String.dateCurrentTime()
        semaphore.signal()
    }
    
    /**
     * @brief 播放器时钟从 指定的进度开始运行
     * @param startProgress : 指定开始运行的进度
     */
    public func startWithProgress(_ startProgress: TimeInterval) {
        semaphore.wait()
        mIsRunning = true
        mBeginTicks = String.dateCurrentTime()
        mDuration = startProgress
        semaphore.signal()
    }
    
    /**
     * @brief 播放器时钟立即停止运行，保留当前的运行进度
     */
    public func stop() {
        semaphore.wait()
        mIsRunning = false
        mDuration += (String.dateCurrentTime() - mBeginTicks) * TimeInterval(mRunSpeed)
        mBeginTicks = String.dateCurrentTime()
        semaphore.signal()
    }
    
    /**
     * @brief 播放器时钟立即停止运行，并且设置指定进度
     * @param setProgress : 指定停止后的运行进度
     */
    public func stopWithProgress(_ setProgress: TimeInterval) {
        semaphore.wait()
        mIsRunning = false
        mBeginTicks = String.dateCurrentTime()
        mDuration = setProgress
        semaphore.signal()
    }
    
    /**
     * @brief 设置运行进度的倍速，通常是 1倍速，2倍速
     * @param setSpeed : 指定当前运行进度
     */
    public func setRunSpeed(_ setSpeed: Int) {
        semaphore.wait()
        if mIsRunning {
            mDuration = (String.dateCurrentTime() - mBeginTicks) * TimeInterval(mRunSpeed)
        }
        mBeginTicks = String.dateCurrentTime()
        mRunSpeed = setSpeed
        semaphore.signal()
    }
    
    /**
     * @brief 直接设置播放器时钟当前进度，通常在 seek时调用
     * @param setProgress : 指定当前运行进度
     */
    public func setProgress(_ setProgress: TimeInterval) {
        semaphore.wait()
        mDuration = setProgress
        mBeginTicks = String.dateCurrentTime()
        semaphore.signal()
    }
    
    /**
     * @brief 获取当前播放器时钟运行进度
     * @return 返回当前时钟进度
     */
    public func getProgress() -> TimeInterval {
        semaphore.wait()
        var time: TimeInterval
        if mIsRunning {
            time = mDuration + (String.dateCurrentTime() - mBeginTicks) * TimeInterval(mRunSpeed)
        } else {
            time = mDuration
        }
        semaphore.signal()
        return time
    }
}
