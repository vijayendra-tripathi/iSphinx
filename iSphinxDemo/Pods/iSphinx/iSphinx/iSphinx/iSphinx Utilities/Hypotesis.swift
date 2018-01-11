//
//  Hypothesis.swift
//  TLSphinx
//
//  Created by Bruno Berisso on 6/1/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

import Foundation

open class Hypothesis {
    
    fileprivate var decoder: Decoder!
    fileprivate var hypString: String = ""
    fileprivate var bestScore: CInt = 0
    
    internal init(decoder: Decoder) {
        self.decoder = decoder
    }
    
    internal func setHypString(hyp: String) {
        self.hypString = hyp
    }
    
    open func getHypString() -> String {
        return hypString.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    internal func setBestScore(bScore: Int) {
        self.bestScore = CInt(bScore)
    }
    
    open func getBestScore() -> Int {
        return Int(bestScore)
    }
}

