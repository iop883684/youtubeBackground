//
//  SimpleCache.swift
//  SongProcessor
//
//  Created by DoLH on 1/16/18.
//  Copyright © 2018 SMJ. All rights reserved.
//

import UIKit

enum CacheType:String {
    
    case playing = "playing"
    case history = "histories"
    
}

struct Video: Codable, Equatable {
    var title:String
    var thumbUrl:String
    var url:String
}

class VideoCache: NSObject {
    
    
    class func clearData(type:CacheType){
        UserDefaults.standard.set(nil, forKey: type.rawValue)
    }
    
    
    class func deleteData(index: Int, type:CacheType) {
        
        guard var histories = UserDefaults.standard.object(forKey: type.rawValue) as? [Data] else { return }
        histories.remove(at: index)
        
        UserDefaults.standard.set(histories, forKey: type.rawValue)
        
    }
    
    class func deleteData(object: Data, type:CacheType) {
        
        guard var histories = UserDefaults.standard.object(forKey: type.rawValue) as? [Data] else {
            return
        }
        
        if let index = histories.firstIndex(of: object) {
            histories.remove(at: index)
        }
        
        UserDefaults.standard.set(histories, forKey: type.rawValue)
        
    }
    
    class func  updateObj(object: Data, at index:Int, type:CacheType){
        
        guard var histories = UserDefaults.standard.object(forKey: type.rawValue) as? [Data] else {
            return
        }
        
        histories[index] = object
        
        UserDefaults.standard.set(histories, forKey: type.rawValue)
        
    }
    
    class func getIndex(object: Data, type:CacheType) -> Int?{
        
        guard let histories = UserDefaults.standard.object(forKey: type.rawValue) as? [Data] else {
            return nil
        }
        
        if let index = histories.firstIndex(of: object) {
            return index
        }
        
        return nil
        
    }
    
    class func appendData(value: Data, type:CacheType) {
        
        var histories = [Data]()
        if let _histories = UserDefaults.standard.object(forKey: type.rawValue) as? [Data] {
            histories = _histories
        }
        
        if !histories.contains(value){
            histories.append(value)
        }
        
        UserDefaults.standard.set(histories, forKey: type.rawValue)
    }
    
    class func getData(type:CacheType) -> [Data]{
        
        guard let histories = UserDefaults.standard.object(forKey: type.rawValue) as? [Data] else {
            return [Data]()
        }
        
        return histories
    }
}
