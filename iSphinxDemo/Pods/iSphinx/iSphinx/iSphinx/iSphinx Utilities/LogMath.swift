//
//  LogMath.swift
//  iSphinx
//
//  Created by Saiful I. Wicaksana on 20/12/17.
//  Copyright © 2017 icaksama. All rights reserved.
//

import Foundation

open class LogMath {
    
    fileprivate var pointer: OpaquePointer!
    
    internal init() {}
    
    public init(decoder: Decoder) {
        pointer = ps_get_logmath(decoder.getPointer())
    }
    
    open func delete() {
        if logmath_free(pointer) < 0 {
            print("Cannot delete logmath")
        }
    }
    
    open func score(prob: Int) -> Double {
        return logmath_exp(pointer, Int32(prob))
    }
    
    internal func getPointer() -> OpaquePointer {
        return pointer
    }
}
