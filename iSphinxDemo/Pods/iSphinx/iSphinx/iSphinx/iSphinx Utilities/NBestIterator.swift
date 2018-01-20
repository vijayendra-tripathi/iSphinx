//
//  NBestIterator.swift
//  iSphinx
//
//  Created by Saiful I. Wicaksana on 21/12/17.
//  Copyright © 2017 icaksama. All rights reserved.
//

import Foundation

open class NBestIterator {
    
    fileprivate var pointer: OpaquePointer!
    fileprivate var iterCount: Int = 0
    fileprivate var currentIter: Int = 0
    fileprivate var bestScore: CInt = 0
    
    internal init() {}
    
    /** Init NBestIterator from current decoder. */
    public init(decoder: Decoder) {
        self.pointer = ps_nbest(decoder.getPointer())
    }
    
    internal func getPointer() -> OpaquePointer {
        return pointer
    }
    
    /** Check NBest still exist in next iterator. */
    open func hasNext() -> Bool {
        if (currentIter + 1) <= iterCount {
            return true
        } else {
            currentIter = 0
            return false
        }
    }
    
    /** Get next NBest from iterator. */
    open func next() -> NBest {
        currentIter += 1
        return NBest(pointer: ps_nbest_next(pointer))
    }
}
