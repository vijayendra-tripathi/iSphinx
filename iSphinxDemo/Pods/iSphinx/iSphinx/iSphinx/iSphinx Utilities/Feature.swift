//
//  Feature.swift
//  iSphinx
//
//  Created by Saiful I. Wicaksana on 22/12/17.
//  Copyright © 2017 icaksama. All rights reserved.
//

import Foundation

open class Feature {
    
    fileprivate var pointer: UnsafeMutablePointer<feat_t>!
    
    internal init() {}
    
    /** Init Feature from current decoder. */
    public init(decoder: Decoder) {
        self.pointer = ps_get_feat(decoder.getPointer())
    }
    
    internal func getPointer() -> UnsafeMutablePointer<feat_t> {
        return pointer
    }
    
    /** Delete feature from memory. */
    open func delete() {
        if feat_free(pointer) < 0 {
            print("Delete feature failed!")
        }
    }
    
    /** Report the feature. */
    open func report() {
        feat_report(pointer)
    }
}
