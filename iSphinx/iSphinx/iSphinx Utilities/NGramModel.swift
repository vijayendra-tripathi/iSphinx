//
//  NGramModel.swift
//  iSphinx
//
//  Created by Saiful I. Wicaksana on 19/12/17.
//  Copyright © 2017 icaksama. All rights reserved.
//

import Foundation

open class NGramModel {
    
    fileprivate var pointer: OpaquePointer!
    
    internal init() {}
    
    internal init(pointer: OpaquePointer) {
        self.pointer = pointer
    }
    
    /** Init the NGramModel from language model file, current config and logmath. Actually, NGramModel is a language model. */
    public init(config: Config, logMath: LogMath, lmFile: String) {
        self.pointer = ngram_model_read(config.getPointer(), lmFile, NGRAM_AUTO, logMath.getPointer())
    }
    
    internal func getPointer() -> OpaquePointer {
        return pointer
    }
    
    /** Delete NGramModel from memory. */
    open func delete() {
        if ngram_model_free(pointer) < 0 {
            print("Cannot delete ngram model")
        }
    }
    
    /** Write NGramModel to a file. */
    open func write(lmPath: String) {
        ngram_model_write(pointer, lmPath, ngram_file_name_to_type(lmPath))
    }
    
    /** Get type of language model from file name. */
    open func strToType(str: String) -> Int {
        return Int(ngram_str_to_type(str).rawValue)
    }
    
    /** Get type of language model from file name and path. */
    open func lmFileToType(lmFile: String) -> Int {
        return Int(ngram_file_name_to_type(lmFile).rawValue)
    }
    
    /** Get type of language model from int to string. */
    open func typeToStr(type: Int) -> String {
        return String.init(cString: ngram_type_to_str(Int32(type)))
    }
    
    /** Set the casefold of NGramModel. */
    open func casefold(kase: Int) {
        ngram_model_casefold(pointer, Int32(kase))
    }
    
    /** Get size of NGramModel. */
    open func size() -> Int {
        return Int(ngram_model_get_size(pointer))
    }
    
    /** Add new word to NGramModel. Make sure the new word is exist in dictionary. */
    open func addWord(word: String, weight: Float) {
        if ngram_model_add_word(pointer, word, weight) == 0 {
            print("Cannot add word \(word) in vocabulary")
        }
    }
    
    /** Get the probability of words. */
    open func prob(stringN: [String]) -> Int {
        return Int(ngram_prob(pointer, Utilities.getPointers(stringN: stringN), int32(stringN.count)))
    }
}
