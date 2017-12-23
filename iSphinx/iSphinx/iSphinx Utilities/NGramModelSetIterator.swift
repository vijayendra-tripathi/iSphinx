//
//  NGramModelSetIterator.swift
//  iSphinx
//
//  Created by Saiful I. Wicaksana on 20/12/17.
//  Copyright © 2017 icaksama. All rights reserved.
//

import Foundation

open class NGramModelSetIterator {
    
    fileprivate var pointer: OpaquePointer!
    fileprivate var iterCount: Int = 0
    fileprivate var currentIter: Int = 0
    
    internal init() {}
    
    public init(nGramSet: NGramModelSet) {
        self.pointer = ngram_model_set_iter(nGramSet.getPointer())
        self.iterCount = Int(ngram_model_set_count(nGramSet.getPointer()))
    }
    
    open func delete() {
        ngram_model_set_iter_free(pointer)
    }
    
    open func hasNext() -> Bool {
        if (currentIter + 1) <= iterCount {
            return true
        } else {
            currentIter = 0
            return false
        }
    }
    
    open func next() -> NGramModel {
        currentIter += 1
        return NGramModel(pointer: ngram_model_set_iter_next(pointer))
    }
}
