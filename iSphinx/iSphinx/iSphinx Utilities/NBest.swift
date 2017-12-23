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
        ps_nbest_seg(pointer, &segmentScore)
    }
    
    internal func getPointer() -> OpaquePointer {
        return pointer
    }
    
    open func delete() {
        ps_nbest_free(pointer)
    }
    
    open func getHypotesisScore() -> Int {
        return Int(hypotesisScore)
    }
    
    open func getSegmentScore() -> Int {
        return Int(segmentScore)
    }
}
