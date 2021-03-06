//
//  Lattice.swift
//  iSphinx
//
//  Created by Saiful I. Wicaksana on 22/12/17.
//  Copyright © 2017 icaksama. All rights reserved.
//

import Foundation

open class Lattice {
    
    fileprivate var pointer: OpaquePointer!
    
    internal init() {}
    
    /** Init Lattice from current decoder. */
    public init(decoder: Decoder) {
        self.pointer = ps_get_lattice(decoder.getPointer())
    }
    
    /** Init Lattice from current decoder and file. */
    public init(decoder: Decoder, filePath: String) {
        self.pointer = ps_lattice_read(decoder.getPointer(), filePath)
    }
    
    internal func getPointer() -> OpaquePointer {
        return pointer
    }
    
    /** Delete Lattice from memory. */
    open func delete() {
        if ps_lattice_free(pointer) < 0 {
            print("Cannot delete lattice")
        }
    }
    
    /** Write current Lattice to file. */
    open func write(toFile: String) {
        if ps_lattice_write(pointer, toFile) < 0 {
            print("Cannot write lattice")
        }
    }
    
    /** Write current Lattice to Htk file */
    open func writeHtk(toFile: String) {
        if ps_lattice_write_htk(pointer, toFile) < 0 {
            print("Caanot write lattice to htk")
        }
    }
    
    /** Get n frames of Lattice. */
    open func nFrames() -> Int {
        return Int(ps_lattice_n_frames(pointer))
    }
}
