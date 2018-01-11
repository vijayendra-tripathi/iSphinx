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
    
    public init(decoder: Decoder) {
        self.pointer = ps_get_fe(decoder.getPointer())
    }
    
    public init(config: Config) {
        self.pointer = fe_init_auto_r(config.getPointer())
    }
    
    public init() {
        self.pointer = fe_init_auto()
    }
    
    internal func getPointer() -> OpaquePointer {
        return pointer
    }
    
    open func delete() {
        if fe_free(pointer) < 0 {
            print("Delete FrontEnd failed!")
        }
    }
    
    open func outputSize() -> Int {
        return Int(fe_get_output_size(pointer))
    }
    
    open func startUtt() {
        if fe_start_utt(pointer) < 0 {
            print("Start FE UTT failed!")
        }
    }
    
    open func endUtt() {
        if fe_end_utt(pointer, &outCepVector, &nFrames) < 0 {
            print("End FE UTT failed!")
        }
    }
    
    open func getOutCepVector() -> Float {
        return outCepVector
    }
    
    open func getNFrames() -> Int {
        return Int(nFrames)
    }
}
