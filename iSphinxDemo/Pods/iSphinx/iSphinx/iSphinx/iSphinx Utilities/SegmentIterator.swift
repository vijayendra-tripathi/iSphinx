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
    
    internal init() {}
    
    /** Init SegmentIterator from current decoder */
    public init(decoder: Decoder) {
        self.pointer = ps_seg_iter(decoder.getPointer())
        if pointer == nil {
            print("seg pointer is nil")
        }
    }
    
    internal func getPointer() -> OpaquePointer {
        return pointer
    }
    
    /** Check segment still exist in next iterator. */
    open func hasNext() -> Bool {
        if pointer == nil {
            return false
        } else if let pSeg = ps_seg_next(pointer) {
            self.pointer = pSeg
            return true
        } else {
            return false
        }
    }
    
    /** Get next segment from iterator. */
    open func next() -> Segment {
        return Segment(pointer: pointer)
    }
}
