//
//  Utilities.swift
//  iSphinx
//
//  Created by Saiful I. Wicaksana on 21/12/17.
//  Copyright © 2017 icaksama. All rights reserved.
//

import Foundation
import AVFoundation

internal class Utilities {
    
    internal static func removePunctuation(words: String) -> String {
        let punctuations = [".",",","?","!","_","-","\\",":"]
        var newWords = words
        for punctuation in punctuations {
            if punctuation == "-" {
                newWords = newWords.replacingOccurrences(of: punctuation, with: " ")
            } else {
                newWords = newWords.replacingOccurrences(of: punctuation, with: "")
            }
        }
        return newWords.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    internal static func removePunctuationArr(words: inout [String]) {
        for i in 0 ..< words.count {
            words[i] = Utilities.removePunctuation(words: words[i])
        }
    }
    
    internal static func getAssetPath() -> String? {
        let bundle = Bundle(for: iSphinx.self).url(forResource: "Assets", withExtension: "bundle")
        return Bundle(url: bundle!)?.bundlePath.appending("/")
    }
    
    internal static func getAcousticPath() -> String? {
        let bundle = Bundle(for: iSphinx.self).url(forResource: "AcousticModel", withExtension: "bundle")
        return Bundle(url: bundle!)?.bundlePath
    }
    
    internal static func getWavURL() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(SEARCH_ID).wav")
    }
    
    internal static func getPointers(stringN: [String]) -> UnsafePointer<UnsafePointer<Int8>?>! {
        var unsafeM: UnsafePointer<UnsafePointer<Int8>?>!
        let cArgs = stringN.map { (name) -> UnsafeMutablePointer<Int8>? in
            return strdup(name)
        }
        cArgs.withUnsafeBytes { (p) -> () in
            unsafeM = p.baseAddress?.assumingMemoryBound(to: UnsafePointer<Int8>?.self)
        }
        return unsafeM
    }
    
    internal static func toNSData(PCMBuffer: AVAudioPCMBuffer) -> NSData {
        let channelCount = 1  // given PCMBuffer channel count is 1
        let channels = UnsafeBufferPointer(start: PCMBuffer.floatChannelData, count: channelCount)
        let ch0Data = NSData(bytes: channels[0], length:Int(PCMBuffer.frameCapacity * PCMBuffer.format.streamDescription.pointee.mBytesPerFrame))
        return ch0Data
    }
    
    internal static func toPCMBuffer(data: NSData) -> AVAudioPCMBuffer {
        let audioFormat = AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatFloat32, sampleRate: 8000, channels: 1, interleaved: false)  // given NSData audio format
        let PCMBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat!, frameCapacity: UInt32(data.length) / (audioFormat?.streamDescription.pointee.mBytesPerFrame)!)
        PCMBuffer?.frameLength = (PCMBuffer?.frameCapacity)!
        let channels = UnsafeBufferPointer(start: PCMBuffer?.floatChannelData, count: Int((PCMBuffer?.format.channelCount)!))
        data.getBytes(UnsafeMutableRawPointer(channels[0]) , length: data.length)
        return PCMBuffer!
    }
    
    internal static func getPointer() {
        
    }
}
