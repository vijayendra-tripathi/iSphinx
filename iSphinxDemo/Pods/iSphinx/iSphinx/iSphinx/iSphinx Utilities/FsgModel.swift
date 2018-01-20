//
//  FsgModel.swift
//  iSphinx
//
//  Created by Saiful I. Wicaksana on 22/12/17.
//  Copyright © 2017 icaksama. All rights reserved.
//

import Foundation

open class FsgModel {
    
    fileprivate var pointer: UnsafeMutablePointer<fsg_model_t>!
    
    internal init() {}
    
    internal init(pointer: UnsafeMutablePointer<fsg_model_t>) {
        self.pointer = pointer
    }
    
    /** Init FsgModel from file and current logmath. */
    public init(filePath: String, logMath: LogMath, lw: Float) {
        self.pointer = fsg_model_readfile(filePath, logMath.getPointer(), lw)
    }
    
    /** Init FsgModel fro current decoder. */
    public init(decoder: Decoder, name: String) {
        self.pointer = ps_get_fsg(decoder.getPointer(), name)
    }
    
    internal func getPointer() -> UnsafeMutablePointer<fsg_model_t> {
        return pointer
    }
    
    /** Delete FsgModel from memory. */
    open func delete() {
        if fsg_model_free(pointer) < 0 {
            print("Delete fsg model failed!")
        }
    }
    
    /** Get word id from string word. */
    open func wordId(word: String) -> Int {
        return Int(fsg_model_word_id(pointer, word))
    }
    
    /** Add new word to FsgModel */
    open func wordAdd(word: String) {
        if fsg_model_word_add(pointer, word) < 0 {
            print("Word add failed!")
        }
    }
    
    open func transAdd(from: Int, to: Int, logP: Int, wid: Int) {
        fsg_model_trans_add(pointer, int32(from), int32(to), int32(logP), int32(wid))
    }
    
    open func nullTransAdd(from: Int, to: Int, logP: Int) -> Int {
        return Int(fsg_model_null_trans_add(pointer, int32(from), int32(to), int32(logP)))
    }
    
    open func tagTransAdd(from: Int, to: Int, logP: Int, wid: Int) -> Int {
        return Int(fsg_model_tag_trans_add(pointer, int32(from), int32(to), int32(logP), int32(wid)))
    }
    
    open func addSilence(silWord: String, state: Int, silProb: Float) -> Int {
        return Int(fsg_model_add_silence(pointer, silWord, Int32(state), silProb))
    }
    
    open func addAlt(baseWord: String, altWord: String) -> Int {
        return Int(fsg_model_add_alt(pointer, baseWord, altWord))
    }
    
    /** Write FsgModel to a file */
    open func write(filePath: String) {
        fsg_model_writefile(pointer, filePath)
    }
    
    /** Write FsgModel to a Symtab file */
    open func writeSymtab(filePath: String) {
        fsg_model_writefile_symtab(pointer, filePath)
    }
    
    /** Write FsgModel to a Fsm file */
    open func writeFsm(filePath: String) {
        fsg_model_writefile_fsm(pointer, filePath)
    }
    
    
}
