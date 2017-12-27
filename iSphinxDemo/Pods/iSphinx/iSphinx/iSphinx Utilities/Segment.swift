//
//  Segment.swift
//  iSphinx
//
//  Created by Saiful I. Wicaksana on 20/12/17.
//  Copyright © 2017 icaksama. All rights reserved.
//

import Foundation

open class Segment {
    
    fileprivate var pointer: OpaquePointer!
    fileprivate var aScore: CInt = 0
    fileprivate var lScore: CInt = 0
    fileprivate var lBack: CInt = 0
    fileprivate var startFrame: CInt = 0
    fileprivate var endFrame: CInt = 0
    fileprivate var prob: CInt = 0
    
    internal init() {}
    
    internal init(pointer: OpaquePointer) {
        self.pointer = pointer
        self.prob = ps_seg_prob(pointer, &aScore, &lScore, &lBack)
        ps_seg_frames(pointer, &startFrame, &endFrame)
    }
    
    internal func getPointer() -> OpaquePointer {
        return pointer
    }
    
    open func delete() {
        ps_seg_free(pointer)
    }
    
    open func getWord() -> String {
        return String.init(cString: ps_seg_word(pointer))
    }
    
    open func getAScore() -> Int {
        return Int(aScore)
    }
    
    open func getLScore() -> Int {
        return Int(lScore)
    }
    
    open func getLBack() -> Int {
        return Int(lBack)
    }
    
    open func getStartFrame() -> Int {
        return Int(startFrame)
    }
    
    open func getEndFrame() -> Int {
        return Int(endFrame)
    }
    
    open func getProb() -> Int {
        return Int(prob)
    }
}
