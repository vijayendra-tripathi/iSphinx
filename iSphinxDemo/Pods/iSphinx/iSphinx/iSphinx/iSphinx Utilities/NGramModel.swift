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
    
    public init(config: Config, logMath: LogMath, lmFile: String) {
        self.pointer = ngram_model_read(config.getPointer(), lmFile, NGRAM_AUTO, logMath.getPointer())
    }
    
    internal func getPointer() -> OpaquePointer {
        return pointer
    }
    
    open func delete() {
        if ngram_model_free(pointer) < 0 {
            print("Cannot delete ngram model")
        }
    }
    
    open func write(lmPath: String) {
        ngram_model_write(pointer, lmPath, ngram_file_name_to_type(lmPath))
    }
    
    open func strToType(str: String) -> Int {
        return Int(ngram_str_to_type(str).rawValue)
    }
    
    open func lmFileToType(lmFile: String) -> Int {
        return Int(ngram_file_name_to_type(lmFile).rawValue)
    }
    
    open func typeToStr(type: Int) -> String {
        return String.init(cString: ngram_type_to_str(Int32(type)))
    }
    
    open func casefold(kase: Int) {
        ngram_model_casefold(pointer, Int32(kase))
    }
    
    open func size() -> Int {
        return Int(ngram_model_get_size(pointer))
    }
    
    open func addWord(word: String, weight: Float) {
        if ngram_model_add_word(pointer, word, weight) == 0 {
            print("Cannot add word \(word) in vocabulary")
        }
    }
    
    open func prob(stringN: [String]) -> Int {
        return Int(ngram_prob(pointer, Utilities.getPointers(stringN: stringN), int32(stringN.count)))
    }
}
