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
    
    /** Delete segment from memory. */
    open func delete() {
        ps_seg_free(pointer)
    }
    
    /** Get word from segment. */
    open func getWord() -> String {
        return String.init(cString: ps_seg_word(pointer))
    }
    
    /** Get AScore from segment. */
    open func getAScore() -> Int {
        return Int(aScore)
    }
    
    /** Get LScore from segment. */
    open func getLScore() -> Int {
        return Int(lScore)
    }
    
    /** Get LBack from segment. */
    open func getLBack() -> Int {
        return Int(lBack)
    }
    
    /** Get Start Frame from segment. */
    open func getStartFrame() -> Int {
        return Int(startFrame)
    }
    
    /** Get End Frame from segment. */
    open func getEndFrame() -> Int {
        return Int(endFrame)
    }
    
    /** Get Prob from segment. */
    open func getProb() -> Int {
        return Int(prob)
    }
}
