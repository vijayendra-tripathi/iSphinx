//
//  NBest.swift
//  iSphinx
//
//  Created by Saiful I. Wicaksana on 21/12/17.
//  Copyright © 2017 icaksama. All rights reserved.
//

import Foundation

open class NBest {
    
    fileprivate var pointer: OpaquePointer!
    fileprivate var hypotesisScore: CInt = 0
    fileprivate var segmentScore: CInt = 0
    
    internal init() {}
    
    internal init(pointer: OpaquePointer) {
        self.pointer = pointer
        ps_nbest_hyp(pointer, &hypotesisScore)
        ps_nbest_seg(pointer)
    }
    
    internal func getPointer() -> OpaquePointer {
        return pointer
    }
    
    /** Delete NBest from memory. */
    open func delete() {
        ps_nbest_free(pointer)
    }
    
    /** Get hypotesis score. */
    open func getHypotesisScore() -> Int {
        return Int(hypotesisScore)
    }
    
    /** Get segment score. */
    open func getSegmentScore() -> Int {
        return Int(segmentScore)
    }
}
