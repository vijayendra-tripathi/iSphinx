//
//  NSFileHandle+Extension.swift
//  TLSphinx
//
//  Created by Bruno Berisso on 5/29/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

import Foundation
import AVFoundation

internal let SEARCH_ID = "icaksama"

internal extension FileHandle {
    
    func reduceChunks(size: Int, reducer: @escaping(NSData) -> ()) {
//        var chuckData = readData(ofLength: size)
//        while chuckData.count > 0 {
//            reducer(chuckData as NSData)
//            chuckData = readData(ofLength: size)
//        }
    }
}

internal extension AVAudioPCMBuffer {
    
    func toNSData() -> NSData {
        let channels = UnsafeBufferPointer(start: int16ChannelData, count: 1)
        let ch0Data = NSData(bytes: channels[0], length:Int(frameCapacity * format.streamDescription.pointee.mBytesPerFrame))
        return ch0Data
    }
    
}

internal extension Array where Element: Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        
        return result
    }
}
