//
//  SegmentIterator.swift
//  iSphinx
//
//  Created by Saiful I. Wicaksana on 20/12/17.
//  Copyright © 2017 icaksama. All rights reserved.
//

import Foundation

open class SegmentIterator {
    
    fileprivate var pointer: OpaquePointer!
    fileprivate var iterCount: Int = 0
    fileprivate var currentIter: Int = 0
    fileprivate var bestScore: CInt = 0
    
    internal init() {}
    
    public init(decoder: Decoder) {
        self.pointer = ps_seg_iter(decoder.getPointer())
    }
    
    internal func getPointer() -> OpaquePointer {
        return pointer
    }
    
    open func getBestScore() -> Int {
        return Int(bestScore)
    }
    
    open func hasNext() -> Bool {
        if (currentIter + 1) <= iterCount {
            return true
        } else {
            currentIter = 0
            return false
        }
    }
    
    open func next() -> Segment {
        currentIter += 1
        return Segment(pointer: ps_seg_next(pointer))
    }
}
