//
//  NSFileHandle+Extension.swift
//  TLSphinx
//
//  Created by Bruno Berisso on 5/29/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

import Foundation
import AVFoundation

extension FileHandle {
    
    func reduceChunks<T>(size: Int, reducer: (NSData) -> T) {
        var chuckData = readData(ofLength: size)
        while chuckData.count > 0 {
            var _ = reducer(chuckData as NSData)
            chuckData = readData(ofLength: size)
        }
    }
}

extension AVAudioPCMBuffer {
    func toNSDate() -> NSData {
        let channels = UnsafeBufferPointer(start: int16ChannelData, count: 1)
        let ch0Data = NSData(bytes: channels[0], length:Int(frameCapacity * format.streamDescription.pointee.mBytesPerFrame))
        return ch0Data
    }
}

extension Array where Element: Equatable {
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
