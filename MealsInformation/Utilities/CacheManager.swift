//
//  CacheManager.swift
//  MealsInformation
//
//  Created by Jay Lliguichushca on 8/27/24.
//

import Foundation
import SwiftUI

/// Manages an in-memory cache with a maximum size limit
actor CacheManager: CacheManagerProtocol {
    static let shared = CacheManager()
    
    private var cache: [String: Any] = [:]
    private var cacheOrder: [String] = []
    private let maxCacheSize: Int = 100
    
    private init() {}
    
    /// Removes oldest items if cache exceeds maximum size
    private func evictIfNeeded() {
        while cacheOrder.count > maxCacheSize {
            let oldestKey = cacheOrder.removeFirst()
            cache.removeValue(forKey: oldestKey)
        }
    }
    
    /// Updates the order of cached items, moving the accessed item to the end
    private func updateCacheOrder(forKey key: String) {
        if let index = cacheOrder.firstIndex(of: key) {
            cacheOrder.remove(at: index)
        }
        cacheOrder.append(key)
        evictIfNeeded()
    }

    /// Stores an image in the cache for a given URL
    func setImage(_ image: Image, forURL url: URL) {
        let key = url.absoluteString
        cache[key] = image
        updateCacheOrder(forKey: key)
    }
     
    /// Retrieves an image from the cache for a given URL
    func getImage(forURL url: URL) -> Image? {
        let key = url.absoluteString
        updateCacheOrder(forKey: key)
        return cache[key] as? Image
    }
    
    /// Stores data in the cache for a given key
    func setData(_ data: Data, forKey key: String) {
        cache[key] = data
        updateCacheOrder(forKey: key)
    }
    
    /// Retrieves data from the cache for a given key
    func getData(forKey key: String) -> Data? {
        updateCacheOrder(forKey: key)
        return cache[key] as? Data
    }
}
