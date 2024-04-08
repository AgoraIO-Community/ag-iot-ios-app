//
//  ThreadSafeDictionary.swift
//  AgoraIotLink
//
//  Created by admin on 2024/3/26.
//

import Foundation


class ThreadSafeDictionary<Key: Hashable, Value> {
    private var dictionary = [Key: Value]()
    private var lock = pthread_rwlock_t()

    init() {
        guard pthread_rwlock_init(&lock, nil) == 0 else {
            fatalError("Failed to initialize pthread_rwlock")
        }
    }

    deinit {
        pthread_rwlock_destroy(&lock)
    }

    func getValue(forKey key: Key, defaultValue: Value) -> Value {
        pthread_rwlock_rdlock(&lock)
//        log.i("\(Thread.current)-----------read----------\(getTimeStamp())")
        defer { pthread_rwlock_unlock(&lock) }
        return dictionary[key, default: defaultValue]
    }
    
    func getAllKeys() -> [Key] {
        pthread_rwlock_rdlock(&lock)
//        print("\(Thread.current)-----------getAllKeys----------\(getTimeStamp())")
        defer { pthread_rwlock_unlock(&lock) }
        return Array(dictionary.keys)
    }
    
    func getAllValues() -> [Value] {
        pthread_rwlock_rdlock(&lock)
        defer { pthread_rwlock_unlock(&lock) }
        return Array(dictionary.values)
    }
    
    func getAllKeysAndValues() -> [(Key, Value)] {
        pthread_rwlock_rdlock(&lock)
        defer { pthread_rwlock_unlock(&lock) }
        return dictionary.map { ($0.key, $0.value) }
    }

    func setValue(_ value: Value, forKey key: Key) {
        pthread_rwlock_wrlock(&lock)
//        log.i("\(Thread.current)-----------save----------\(getTimeStamp())")
        dictionary[key] = value
        pthread_rwlock_unlock(&lock)
    }
    
    func removeValue(forKey key: Key) -> Value? {
        pthread_rwlock_wrlock(&lock)
//        log.i("\(Thread.current)-----------removeValue----------\(getTimeStamp())")
        defer { pthread_rwlock_unlock(&lock) }
        return dictionary.removeValue(forKey: key)
    }

    func removeAll() {
        pthread_rwlock_wrlock(&lock)
//        log.i("\(Thread.current)-----------removeAll----------\(getTimeStamp())")
        defer { pthread_rwlock_unlock(&lock) }
        dictionary.removeAll()
    }

    
    func getTimeStamp()->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSS"

        let currentTime = Date()
        let formattedTime = dateFormatter.string(from: currentTime)
        
        return formattedTime
    }
    
}
