//
//  FrontEnd.swift
//  iSphinx
//
//  Created by Saiful I. Wicaksana on 22/12/17.
//  Copyright © 2017 icaksama. All rights reserved.
//

import Foundation

open class FrontEnd {
    
    fileprivate var pointer: OpaquePointer!
    fileprivate var outCepVector: CFloat = 0
    fileprivate var nFrames: CInt = 0
    
    /** Init FrontEnd from current decoder. */
    public init(decoder: Decoder) {
        self.pointer = ps_get_fe(decoder.getPointer())
    }
    
    /** Init FrontEnd from current config class. */
    public init(config: Config) {
        self.pointer = fe_init_auto_r(config.getPointer())
    }
    
    /** Init FrontEnd with default setting. */
    public init() {
        self.pointer = fe_init_auto()
    }
    
    internal func getPointer() -> OpaquePointer {
        return pointer
    }
    
    /** Delete FrontEnd from memory. */
    open func delete() {
        if fe_free(pointer) < 0 {
            print("Delete FrontEnd failed!")
        }
    }
    
    /** Get output size of FrontEnd. */
    open func outputSize() -> Int {
        return Int(fe_get_output_size(pointer))
    }
    
    /** Start utterance */
    open func startUtt() {
        if fe_start_utt(pointer) < 0 {
            print("Start FE UTT failed!")
        }
    }
    
    /** Stop utterance */
    open func endUtt() {
        if fe_end_utt(pointer, &outCepVector, &nFrames) < 0 {
            print("End FE UTT failed!")
        }
    }
    
    /** Get out cep vector. */
    open func getOutCepVector() -> Float {
        return outCepVector
    }
    
    /** Get n frames of Front End */
    open func getNFrames() -> Int {
        return Int(nFrames)
    }
}
